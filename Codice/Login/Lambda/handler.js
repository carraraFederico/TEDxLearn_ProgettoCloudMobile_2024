const connect_to_db = require('./db');

const login = require('./Login');

module.exports.check_login = (event, context, callback) => {
    context.callbackWaitsForEmptyEventLoop = false;
    console.log('Received event:', JSON.stringify(event, null, 2));
    let body = {}
    if (event.body) {
        body = JSON.parse(event.body)
    }
    // set default
    if(!body.email) {
        callback(null, {
                    statusCode: 500,
                    headers: { 'Content-Type': 'text/plain' },
                    body: 'Email is null!'
        })
    }
    else if(!body.password) {
        callback(null, {
                    statusCode: 500,
                    headers: { 'Content-Type': 'text/plain' },
                    body: 'Password is null!'
        })
    }
    
    connect_to_db().then(() => {
        console.log('Controllo login');
        login.findOne({_id: body.email, password: body.password})
            .then(logins => {
                    if (!logins) {
                    console.log('Utente non trovato, controlla i campi!');
                    return callback(null, {
                        statusCode: 404,
                        headers: { 'Content-Type': 'text/plain' },
                        body: 'Errore nei dati del login, controlla i campi!'
                    });
                }
                console.log('Login effettuato correttamente', logins);
                callback(null, {
                    statusCode: 200,
                    headers: { 'Content-Type': 'application/json' },
                    body: 'Login effettuato correttamente ' + JSON.stringify({ "Email": logins._id, "Password": logins.password})
                });}
            )
            .catch(err =>
                callback(null, {
                    statusCode: err.statusCode || 500,
                    headers: { 'Content-Type': 'text/plain' },
                    body: 'Impossibile effettuare il login!'
                })
            );
    });
};