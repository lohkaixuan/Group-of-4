const { bucket } = require('../config/firebase');
const { v4: uuidv4 } = require('uuid');

async function uploadToStorage(file, folder) {
  const filename = `${folder}/${uuidv4()}_${file.originalname}`;
  const fileUpload = bucket.file(filename);
  await fileUpload.save(file.buffer, {
    metadata: { contentType: file.mimetype },
  });
  await fileUpload.makePublic();
  return `https://storage.googleapis.com/${bucket.name}/${filename}`;
}

module.exports = uploadToStorage;
