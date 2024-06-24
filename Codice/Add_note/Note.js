const mongoose = require('mongoose');

const note_schema = new mongoose.Schema({
    _id: String,
    id_video: String,
    testo: String
}, {collection: 'note_data', versionKey: false});

module.exports = mongoose.model('note', note_schema);