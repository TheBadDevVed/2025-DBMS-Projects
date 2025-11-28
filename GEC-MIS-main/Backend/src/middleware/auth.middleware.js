import jwt from 'jsonwebtoken';
import Student from '../models/student.model.js';
import Admin from '../models/admin.model.js';

// General middleware to protect routes, checks for student or admin
export const protectAll = async (req, res, next) => {
    let token;

    // 1) Try Authorization header (Bearer token) — used by mobile apps / axios
    const authHeader = req.headers?.authorization || req.headers?.Authorization;
    if (authHeader && typeof authHeader === 'string' && authHeader.startsWith('Bearer ')) {
        token = authHeader.split(' ')[1];
    }

    // 2) Fallback to cookie token (web usage)
    if (!token && req.cookies && req.cookies.token) {
        token = req.cookies.token;
    }

    // If still no token, return unauthorized
    if (!token) {
        return res.status(401).json({ message: 'Not authorized, no token' });
    }

    try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET);

        // Try finding user as Student first
        let user = await Student.findById(decoded.id).select('-password');
        if (user) {
            req.user = user; // Attach general user info
            req.student = user; // Attach specific student info
            return next(); // Student found, proceed
        }

        // If not a student, try finding as Admin
        user = await Admin.findById(decoded.id).select('-password');
        if (user) {
            req.user = user; // Attach general user info
            // req.admin = user; // Optionally attach specific admin info if needed later
            return next(); // Admin found, proceed
        }

        // If user ID in token doesn't match any user
        return res.status(401).json({ message: 'Not authorized, user not found' });

    } catch (error) {
        console.error('Token verification failed:', error);
        // Handle different JWT errors specifically if needed (e.g., TokenExpiredError)
        if (error.name === 'JsonWebTokenError') {
            return res.status(401).json({ message: 'Not authorized, token invalid' });
        }
        if (error.name === 'TokenExpiredError') {
            return res.status(401).json({ message: 'Not authorized, token expired' });
        }
        return res.status(401).json({ message: 'Not authorized, token failed' });
    }
};
