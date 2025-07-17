// server/utils/validation.js

function validateIC(ic_number) {
  const icRegex = /^\d{6}-\d{2}-\d{4}$/;
  return icRegex.test(ic_number);
}

function validatePhone(phone) {
  const phoneRegex = /^\d{8,15}$/;
  return phoneRegex.test(phone);
}

function validateEmail(email) {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
}

function validatePin(pin) {
  const pinRegex = /^\d{6}$/;
  return pinRegex.test(pin);
}

module.exports = {
  validateIC,
  validatePhone,
  validateEmail,
  validatePin
};
