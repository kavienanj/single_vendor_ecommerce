const jwt = require('jsonwebtoken');

const authMiddleware = (req, res, next) => {
    const authHeader = req.headers['authorization'];
    if (!authHeader) {
        next();
        return;
    }
    const token = authHeader && authHeader.split(' ')[1];

    // if (!token) {
    //     return res.sendStatus(401); // Unauthorized
    // }

    jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
        if (err) {
            return res.sendStatus(403); // Forbidden
        }
        req.user = {
            id: user.id,
            email: user.email,
            first_name: user.first_name,
            last_name: user.last_name,
            role_id: user.role_id,
        }
        // console.log('req.user:', req.user);
        next();
    });
};

module.exports = authMiddleware;
