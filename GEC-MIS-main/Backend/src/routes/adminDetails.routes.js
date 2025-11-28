import express from "express";

import {addStudentDetails, studentDetailsForAdmin, updateStudentDetails} from '../controller/adminDetails.controller.js'
import { protectAdmin } from "../middleware/protectAdmin.js";
import { createNotice, deleteNotice, getAllNotices, updateNotice} from "../controller/notice.controller.js";


const router=express.Router();

router.get('/studentDetails',studentDetailsForAdmin)
router.post ('/addStudentDetails',addStudentDetails)
router.patch('/updateStudentDetails', updateStudentDetails);

router.post('/createNotice',createNotice)
router.get('/viewNotice',getAllNotices)
router.put('/updateNotice',updateNotice)
router.delete('/deleteNotice',deleteNotice)

export default router