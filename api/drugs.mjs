const MFDS_BASE = 'https://apis.data.go.kr/1471000';
const PERMIT_BASE = `${MFDS_BASE}/DrugPrdtPrmsnInfoService07`;
const EASY_BASE = `${MFDS_BASE}/DrbEasyDrugInfoService`;
const PILL_BASE = `${MFDS_BASE}/MdcinGrnIdntfcInfoService03`;

export default async function handler(request, response) {
  if (request.method !== 'GET') {
    return response.status(405).json({error: 'Method not allowed'});
  }

  const serviceKey = process.env.MFDS_SERVICE_KEY?.trim();
  if (!serviceKey) {
    return response.status(503).json({
      error: 'MFDS_SERVICE_KEY is not configured',
      code: 'MFDS_KEY_MISSING',
    });
  }

  response.setHeader(
    'Cache-Control',
    'public, s-maxage=300, stale-while-revalidate=3600',
  );

  try {
    const id = firstQueryValue(request.query.id);
    if (id) {
      const item = await getDrugDetail(id, serviceKey);
      if (!item) {
        return response.status(404).json({error: 'Drug not found'});
      }
      return response.status(200).json({
        item: attachImageProxy(item, request),
      });
    }

    const query = firstQueryValue(request.query.q)?.trim();
    if (!query) {
      return response.status(400).json({error: 'q is required'});
    }

    const items = await searchDrugs(query, serviceKey);
    return response.status(200).json({
      items: items.map((item) => attachImageProxy(item, request)),
    });
  } catch (error) {
    console.error('MFDS drug API error', safeErrorMessage(error));
    return response.status(502).json({
      error: '공식 의약품 정보를 불러오지 못했습니다.',
      code: 'MFDS_UPSTREAM_ERROR',
    });
  }
}

async function searchDrugs(query, serviceKey) {
  const common = {pageNo: '1', numOfRows: '30', type: 'json'};
  const requests = [
    fetchMfData(
      `${PERMIT_BASE}/getDrugPrdtPrmsnInq07`,
      {...common, item_name: query},
      serviceKey,
    ),
    fetchMfData(
      `${PERMIT_BASE}/getDrugPrdtPrmsnInq07`,
      {...common, item_ingr_name: query},
      serviceKey,
    ),
    fetchMfData(
      `${PERMIT_BASE}/getDrugPrdtPrmsnInq07`,
      {...common, entp_name: query},
      serviceKey,
    ),
  ];

  const settled = await Promise.allSettled(requests);
  const merged = new Map();
  for (const result of settled) {
    if (result.status !== 'fulfilled') continue;
    for (const raw of extractItems(result.value)) {
      const item = normalizeDrug(raw);
      if (item.id) merged.set(item.id, item);
    }
  }
  if (merged.size === 0 && settled.every((item) => item.status === 'rejected')) {
    throw new Error('All MFDS search requests failed');
  }
  return [...merged.values()].slice(0, 50);
}

async function getDrugDetail(id, serviceKey) {
  const detailRequests = await Promise.allSettled([
    fetchMfData(
      `${PERMIT_BASE}/getDrugPrdtPrmsnDtlInq06`,
      {item_seq: id, type: 'json'},
      serviceKey,
    ),
    fetchMfData(
      `${PERMIT_BASE}/getDrugPrdtPrmsnInq07`,
      {
        prdlst_Stdr_code: id,
        pageNo: '1',
        numOfRows: '1',
        type: 'json',
      },
      serviceKey,
    ),
    fetchMfData(
      `${EASY_BASE}/getDrbEasyDrugList`,
      {itemSeq: id, pageNo: '1', numOfRows: '1', type: 'json'},
      serviceKey,
    ),
    fetchMfData(
      `${PILL_BASE}/getMdcinGrnIdntfcInfoList03`,
      {item_seq: id, pageNo: '1', numOfRows: '1', type: 'json'},
      serviceKey,
    ),
  ]);

  const rawItems = detailRequests
    .filter((result) => result.status === 'fulfilled')
    .flatMap((result) => extractItems(result.value));
  if (rawItems.length === 0) return null;

  const combined = Object.assign({}, ...rawItems);
  return normalizeDrug(combined);
}

async function fetchMfData(endpoint, params, serviceKey) {
  const url = new URL(endpoint);
  url.searchParams.set('serviceKey', serviceKey);
  for (const [key, value] of Object.entries(params)) {
    if (value !== undefined && value !== null && value !== '') {
      url.searchParams.set(key, value);
    }
  }

  const upstream = await fetch(url, {
    headers: {Accept: 'application/json'},
    signal: AbortSignal.timeout(7000),
  });
  if (!upstream.ok) {
    throw new Error(`MFDS ${upstream.status}`);
  }
  const text = await upstream.text();
  try {
    return JSON.parse(text);
  } catch {
    throw new Error('MFDS returned a non-JSON response');
  }
}

function extractItems(payload) {
  const body =
    payload?.response?.body ??
    payload?.body ??
    payload?.response ??
    payload ??
    {};
  const items = body?.items?.item ?? body?.items ?? body?.item ?? [];
  if (Array.isArray(items)) return items.filter(isObject);
  return isObject(items) ? [items] : [];
}

function normalizeDrug(raw) {
  const id = pick(raw, [
    'ITEM_SEQ',
    'itemSeq',
    'item_seq',
    'PRDLST_STDR_CODE',
    'prdlst_Stdr_code',
  ]);
  const specialty = pick(raw, [
    'SPCLTY_PBLC',
    'spclty_pblc',
    'ETC_OTC_CODE',
    'etcOtcCode',
  ]);
  const updatedAt = normalizeDate(
    pick(raw, ['UPDATE_DE', 'updateDe', 'CHANGE_DATE', 'changeDate']),
  );
  const warning = plainText(
    pickRaw(raw, [
      'atpnWarnQesitm',
      'ATPN_WARN_QESITM',
      'NB_DOC_DATA',
      'nb_doc_data',
    ]),
  );
  const precaution = plainText(
    pickRaw(raw, ['atpnQesitm', 'ATPN_QESITM', 'NB_DOC_DATA', 'nb_doc_data']),
  );

  return {
    id,
    productName: pick(raw, ['ITEM_NAME', 'itemName', 'item_name']),
    ingredientKor: pick(raw, [
      'ITEM_INGR_NAME',
      'item_ingr_name',
      'MAIN_ITEM_INGR',
      'main_item_ingr',
    ]),
    ingredientEng: pick(raw, [
      'INGR_ENG_NAME',
      'ingr_eng_name',
      'MAIN_INGR_ENG',
      'main_ingr_eng',
      'ITEM_INGR_NAME',
      'item_ingr_name',
    ]),
    manufacturer: pick(raw, ['ENTP_NAME', 'entpName', 'entp_name']),
    category: pick(raw, [
      'CLASS_NAME',
      'class_name',
      'PRDUCT_TYPE',
      'prduct_type',
    ]),
    dosageForm: pick(raw, [
      'FORM_CODE_NAME',
      'form_code_name',
      'DRUG_SHAPE',
      'drug_shape',
    ]),
    administrationRoute: pick(raw, [
      'ROUTE_NAME',
      'route_name',
      'ADMIN_ROUTE',
      'admin_route',
    ]),
    efficacy: plainText(
      pickRaw(raw, ['efcyQesitm', 'EFCY_QESITM', 'EE_DOC_DATA', 'ee_doc_data']),
    ),
    dosage: plainText(
      pickRaw(raw, [
        'useMethodQesitm',
        'USE_METHOD_QESITM',
        'UD_DOC_DATA',
        'ud_doc_data',
      ]),
    ),
    nursingPoints: {
      beforeAdministration: [],
      afterAdministration: [],
      commonAdverseEffects: [],
      cautionPatients: [],
    },
    contraindication: warning,
    precaution,
    interaction: plainText(
      pickRaw(raw, ['intrcQesitm', 'INTRC_QESITM']),
    ),
    adverseEffect: plainText(
      pickRaw(raw, ['seQesitm', 'SE_QESITM']),
    ),
    storage: plainText(
      pickRaw(raw, [
        'depositMethodQesitm',
        'DEPOSIT_METHOD_QESITM',
        'STORAGE_METHOD',
        'storage_method',
      ]),
    ),
    insuranceCode: nullablePick(raw, ['EDI_CODE', 'edi_code']),
    atcCode: nullablePick(raw, ['ATC_CODE', 'atc_code']),
    isPrescription: specialty.includes('전문'),
    imageUrl: nullablePick(raw, [
      'itemImage',
      'ITEM_IMAGE',
      'item_image',
      'BIG_PRDT_IMG_URL',
    ]),
    source: '식품의약품안전처 의약품 허가정보',
    sourceUrl: id
      ? `https://nedrug.mfds.go.kr/pbp/CCBBB01/getItemDetail?itemSeq=${encodeURIComponent(id)}`
      : 'https://nedrug.mfds.go.kr/',
    updatedAt,
  };
}

function pick(raw, keys, fallback = '정보 없음') {
  const value = pickRaw(raw, keys);
  const text = plainText(value);
  return text || fallback;
}

function nullablePick(raw, keys) {
  const value = plainText(pickRaw(raw, keys));
  return value || null;
}

function pickRaw(raw, keys) {
  if (!isObject(raw)) return undefined;
  for (const key of keys) {
    if (raw[key] !== undefined && raw[key] !== null) return raw[key];
  }
  const lookup = new Map(
    Object.entries(raw).map(([key, value]) => [key.toLowerCase(), value]),
  );
  for (const key of keys) {
    const value = lookup.get(key.toLowerCase());
    if (value !== undefined && value !== null) return value;
  }
  return undefined;
}

function plainText(value) {
  if (value === undefined || value === null) return '';
  if (Array.isArray(value)) return value.map(plainText).filter(Boolean).join(' ');
  if (isObject(value)) {
    return Object.values(value).map(plainText).filter(Boolean).join(' ');
  }
  return String(value)
    .replace(/<[^>]*>/g, ' ')
    .replace(/&nbsp;/gi, ' ')
    .replace(/&amp;/gi, '&')
    .replace(/&lt;/gi, '<')
    .replace(/&gt;/gi, '>')
    .replace(/\s+/g, ' ')
    .trim();
}

function normalizeDate(value) {
  const digits = String(value ?? '').replace(/\D/g, '');
  if (digits.length >= 8) {
    return `${digits.slice(0, 4)}-${digits.slice(4, 6)}-${digits.slice(6, 8)}T00:00:00.000Z`;
  }
  return new Date(0).toISOString();
}

function firstQueryValue(value) {
  return Array.isArray(value) ? value[0] : value;
}

function isObject(value) {
  return value !== null && typeof value === 'object' && !Array.isArray(value);
}

function safeErrorMessage(error) {
  return error instanceof Error ? error.message : String(error);
}

function attachImageProxy(item, request) {
  if (!item.imageUrl) return item;
  const protocol = request.headers['x-forwarded-proto'] ?? 'https';
  const host = request.headers.host;
  if (!host) return item;
  return {
    ...item,
    imageUrl: `${protocol}://${host}/api/drug-image?url=${encodeURIComponent(item.imageUrl)}`,
  };
}
