export default async function handler(request, response) {
  if (request.method !== 'GET') {
    return response.status(405).json({error: 'Method not allowed'});
  }

  const value = firstQueryValue(request.query.url);
  if (!value) {
    return response.status(400).json({error: 'url is required'});
  }

  let imageUrl;
  try {
    imageUrl = new URL(value);
  } catch {
    return response.status(400).json({error: 'Invalid image URL'});
  }

  if (
    imageUrl.protocol !== 'https:' ||
    !(
      imageUrl.hostname === 'mfds.go.kr' ||
      imageUrl.hostname.endsWith('.mfds.go.kr')
    )
  ) {
    return response.status(403).json({error: 'Image host is not allowed'});
  }

  try {
    const upstream = await fetch(imageUrl, {
      signal: AbortSignal.timeout(7000),
      headers: {Accept: 'image/*'},
    });
    if (!upstream.ok) {
      return response.status(502).json({error: 'Image upstream failed'});
    }

    const contentType = upstream.headers.get('content-type') ?? '';
    if (!contentType.startsWith('image/')) {
      return response.status(502).json({error: 'Upstream is not an image'});
    }

    const bytes = Buffer.from(await upstream.arrayBuffer());
    response.setHeader('Content-Type', contentType);
    response.setHeader(
      'Cache-Control',
      'public, max-age=86400, s-maxage=604800, stale-while-revalidate=2592000',
    );
    return response.status(200).send(bytes);
  } catch {
    return response.status(502).json({error: 'Image upstream failed'});
  }
}

function firstQueryValue(value) {
  return Array.isArray(value) ? value[0] : value;
}
