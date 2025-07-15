// helpers/responseHelper.js

/**
 * Send a standardized success response
 * @param {Object} res - Express response object
 * @param {String} message - A human-readable message
 * @param {Object|Array} data - The data payload
 */
function success(res, message = 'Success', data = []) {
    return res.status(200).json({
        success: true,
        message,
        data
    });
}

/**
 * Send a standardized client error response (e.g. validation error)
 * @param {Object} res - Express response object
 * @param {String} message - A human-readable message
 * @param {Object|Array} data - Optional extra info
 */
function fail(res, message = 'Bad Request', data = []) {
    return res.status(400).json({
        success: false,
        message,
        data
    });
}

/**
 * Send a standardized server error response
 * @param {Object} res - Express response object
 * @param {String} message - A human-readable message
 * @param {Object|Array} data - Optional extra info
 */
function error(res, message = 'Internal Server Error', data = []) {
    return res.status(500).json({
        success: false,
        message,
        data
    });
}

module.exports = {
    success,
    fail,
    error
};