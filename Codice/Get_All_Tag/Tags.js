const mongoose = require('mongoose');

const tag_schema = new mongoose.Schema({
    _id: String,
    videos_list: Array
}, { collection: 'video_da_tag' });

module.exports = mongoose.model('tags', tag_schema);