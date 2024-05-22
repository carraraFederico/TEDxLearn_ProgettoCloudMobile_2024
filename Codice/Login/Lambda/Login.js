const mongoose = require('mongoose');

const login_schema = new mongoose.Schema({
    _id: String,
    username: String,
    password: String
}, { collection: 'login_data' });

module.exports = mongoose.model('login', login_schema);