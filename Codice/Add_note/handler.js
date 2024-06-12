const connect_to_db = require('./db');

const note = require('./Note');

module.exports.add_note = (event, context, callback) => {
    context.callbackWaitsForEmptyEventLoop = false;
    console.log('Received event:', JSON.stringify(event, null, 2));
    let body = {}
    if (event.body) {
        body = JSON.parse(event.body)
    }
    
    if(!body.id) {
        callback(null, {
                    statusCode: 500,
                    headers: { 'Content-Type': 'text/plain' },
                    body: 'Inserire id della nota'
        })
    }
    else if(!body.video) {
        callback(null, {
                    statusCode: 500,
                    headers: { 'Content-Type': 'text/plain' },
                    body: 'Inserire id del video'
        })
    }
    else if(!body.nota) {
        callback(null, {
                    statusCode: 500,
                    headers: { 'Content-Type': 'text/plain' },
                    body: 'Inserire il testo della nota'
        })
    }
    
    connect_to_db().then(() => {
        console.log('Aggiunta nota');
        note.insertOne({_id: body.id, id_video: body.video, testo: body.nota});
            /*.then(notes => {
                callback(null, {
                    statusCode: 200,
                    body: JSON.stringify(notes)
                })
            })
            .catch(err =>
                callback(null, {
                    statusCode: err.statusCode,
                    headers: { 'Content-Type': 'text/plain' },
                    body: 'Errore di inserimento'
                })
            );*/
    });
};