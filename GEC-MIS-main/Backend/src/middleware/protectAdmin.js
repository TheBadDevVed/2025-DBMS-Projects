import jwt from 'jsonwebtoken';
import Admin from '../models/admin.model.js';

export const protectAdmin = async (req, res, next) => {
    let token;

    if (req.cookies.token) {
        try {
            token = req.cookies.token;
            
            const decoded = jwt.verify(token, process.env.JWT_SECRET);
            
            // Find the user as an Admin
            const admin = await Admin.findById(decoded.id).select('-password');

            if (admin) {
                req.user = admin; // Attach admin user info
                return next(); // Admin found, proceed
            }

            // If user ID in token is not an admin
            return res.status(403).json({ message: 'Forbidden: Access restricted to admins' });

        } catch (error) {
            console.error('Admin token verification failed:', error);
            if (error.name === 'JsonWebTokenError') {
                return res.status(401).json({ message: 'Not authorized, token invalid' });
            }
             if (error.name === 'TokenExpiredError') {
                return res.status(401).json({ message: 'Not authorized, token expired' });
            }
            return res.status(401).json({ message: 'Not authorized, token failed' });
        }
    }

    // If no token is found in cookies
    if (!token) {
        return res.status(401).json({ message: 'Not authorized, no token' });
    }
};