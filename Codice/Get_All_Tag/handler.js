const connect_to_db = require('./db');
const tag = require('./Tags');

module.exports.get_all_tag = (event, context, callback) => {
    context.callbackWaitsForEmptyEventLoop = false;
    console.log('Received event:', JSON.stringify(event, null, 2));
    
    let body = {};
    if (event.body) {
        body = JSON.parse(event.body);
    }
    
    connect_to_db().then(() => {
        console.log('=> get_all tags');
        tag.find({})
            .select('_id')
            .then(tags => {
                callback(null, {
                    statusCode: 200,
                    body: JSON.stringify(tags)
                });
            })
            .catch(err =>
                callback(null, {
                    statusCode: err.statusCode || 500,
                    headers: { 'Content-Type': 'text/plain' },
                    body: 'Could not fetch the tags.'
                })
            );
    });
};
