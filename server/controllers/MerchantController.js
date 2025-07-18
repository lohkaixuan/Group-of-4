const { db } = require('../config/firebase');
const { createWallet } = require('../models/WalletModel');
const { addBlock, getMerchantBlock, encrypt, decrypt } = require('../utils/blockchain');

// ✅ Approve merchant by userId
exports.approveMerchantById = async (userId) => {
  const ref = db.collection('users').doc(userId);
  const snap = await ref.get();
  if (!snap.exists) return;

  const user = snap.data();
  let updateData = { status: 'approved' };

  // ✅ Check & create personal wallet
  const personalSnap = await db.collection('wallets')
    .where('user_id', '==', userId)
    .where('type', '==', 'personal')
    .limit(1)
    .get();
  if (personalSnap.empty) {
    const personalWallet = await createWallet(userId, 'personal');
    updateData.personal_wallet_id = personalWallet.wallet_id;
    console.log('✅ Created personal wallet');
  } else {
    console.log('ℹ️ Personal wallet already exists');
  }

  // ✅ Check & create merchant wallet
  const merchantSnap = await db.collection('wallets')
    .where('user_id', '==', userId)
    .where('type', '==', 'merchant')
    .limit(1)
    .get();
  if (merchantSnap.empty) {
    const merchantWallet = await createWallet(userId, 'merchant');
    updateData.merchant_wallet_id = merchantWallet.wallet_id;
    console.log('✅ Created merchant wallet');
  } else {
    console.log('ℹ️ Merchant wallet already exists');
  }

  // ✅ Update Firestore user document
  await ref.update(updateData);

  // ✅ Prepare merchant block data
  const merchantBlockData = {
    id: userId,
    name: user.name,
    email: user.email,
    phone: user.phone,
    business_type: user.business_type,
    category_service: user.category_service,
    ssm_certificate: encrypt(user.ssm_certificate || ''), // encrypt the SSM cert before storing
    approved_at: new Date().toISOString(),
  };

  // ✅ Add to blockchain
  const merchantBlock = await addBlock(merchantBlockData);
  console.log('✅ Block created on-chain:', merchantBlock.hash);
};

// ✅ Public API helper to fetch merchant block
exports.getMerchantBlockchainData = async (userId) => {
  const block = await getMerchantBlock(userId);
  if (!block) return null;

  // decrypt SSM if exists
  const decryptedSSM = block.data?.ssm_certificate
    ? decrypt(block.data.ssm_certificate)
    : null;

  return {
    ...block,
    data: {
      ...block.data,
      ssm_certificate: decryptedSSM
    }
  };
};
