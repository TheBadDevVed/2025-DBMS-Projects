import Notice from '../models/notice.model.js';
import mongoose from 'mongoose';

// Create a new notice
const createNotice = async (req, res) => {
  try {
    const { title, body, description, content } = req.body;
    // Accept flexible body field names and do not hard-require auth for creation (route currently not protected)
    const text = body ?? description ?? content;

    if (!title || !text) {
      return res.status(400).json({ success: false, message: 'Title and body/description are required.' });
    }

    const newNotice = new Notice({
      title,
      body: text,
    });

    const savedNotice = await newNotice.save();
    res.status(201).json({ success: true, data: savedNotice });
  } catch (error) {
    console.error('Error creating notice:', error);
    res.status(500).json({ success: false, message: 'Failed to create notice.', error: error.message });
  }
};

// Get all notices
const getAllNotices = async (req, res) => {
  try {
    const notices = await Notice.find().sort({ createdAt: -1 });
    res.status(200).json({ success: true, data: notices });
  } catch (error) {
    console.error('Error fetching notices:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch notices.', error: error.message });
  }
};

// Get a single notice by ID
const getNoticeById = async (req, res) => {
  try {
    const { id } = req.params;

    if (!mongoose.Types.ObjectId.isValid(id)) {
        return res.status(400).json({ success: false, message: 'Invalid notice ID format.' });
    }

    const notice = await Notice.findById(id).populate('userid', 'name email'); // Populate admin details

    if (!notice) {
      return res.status(404).json({ success: false, message: 'Notice not found.' });
    }

    res.status(200).json({ success: true, data: notice });
  } catch (error) {
    console.error('Error fetching notice by ID:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch notice.', error: error.message });
  }
};

// Update a notice by ID
const updateNotice = async (req, res) => {
  try {
    const { id } = req.params;
    const { title, body, description, content } = req.body;

    if (!mongoose.Types.ObjectId.isValid(id)) {
        return res.status(400).json({ success: false, message: 'Invalid notice ID format.' });
    }

    const noticeToUpdate = await Notice.findById(id);

    if (!noticeToUpdate) {
        return res.status(404).json({ success: false, message: 'Notice not found.' });
    }

    const updateData = {};
    if (title) updateData.title = title;
    const text = body ?? description ?? content;
    if (text) updateData.body = text;

    if (Object.keys(updateData).length === 0) {
        return res.status(400).json({ success: false, message: 'No update data provided.' });
    }

    const updatedNotice = await Notice.findByIdAndUpdate(id, updateData, {
      new: true,
      runValidators: true,
    }).populate('userid', 'name email');

    res.status(200).json({ success: true, data: updatedNotice });
  } catch (error) {
    console.error('Error updating notice:', error);
    res.status(500).json({ success: false, message: 'Failed to update notice.', error: error.message });
  }
};

// Delete a notice by ID
const deleteNotice = async (req, res) => {
  try {
    const { id } = req.params;
    // Assuming admin ID is available in req.admin._id after authentication middleware
    const requestingAdminId = req.admin?._id;

    if (!requestingAdminId) {
        return res.status(401).json({ success: false, message: 'Admin authentication required.' });
    }


    if (!mongoose.Types.ObjectId.isValid(id)) {
        return res.status(400).json({ success: false, message: 'Invalid notice ID format.' });
    }

    const noticeToDelete = await Notice.findById(id);

    if (!noticeToDelete) {
        return res.status(404).json({ success: false, message: 'Notice not found.' });
    }
    await Notice.findByIdAndDelete(id);

    res.status(200).json({ success: true, message: 'Notice deleted successfully.' });
  } catch (error) {
    console.error('Error deleting notice:', error);
    res.status(500).json({ success: false, message: 'Failed to delete notice.', error: error.message });
  }
};

export {
  createNotice,
  getAllNotices,
  getNoticeById,
  updateNotice,
  deleteNotice,
};