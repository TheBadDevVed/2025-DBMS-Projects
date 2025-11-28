import express from "express"
import { adminRegister,adminLogin,adminLogout } from "../controller/adminauth.controller.js";


const router = express.Router();

router.post('/adminRegister',adminRegister)
router.post('/adminLogin',adminLogin)
router.post('/adminLogout',adminLogout)



export default router;