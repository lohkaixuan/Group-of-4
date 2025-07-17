const { bucket } = require('../config/firebase');

async function generateDownloadUrl(filename) {
  const file = bucket.file(filename);
  const [url] = await file.getSignedUrl({
    action: 'read',
    expires: Date.now() + 60 * 60 * 1000 // 1 hour
  });
  return url;
}

module.exports = generateDownloadUrl;
