import Student from '../models/student.model.js';
import Academic from '../models/academic.model.js';
import Fee from '../models/fee.model.js';
import Department from '../models/department.model.js';

// Modified function without middleware dependency
export const getStudentDetails = async (req, res) => {
  try {
    const { studentId } = req.params;

    if (!studentId) {
      return res.status(400).json({ message: 'Student ID is required' });
    }

    const student = await Student.findById(studentId).select('-password');

    if (!student) {
      return res.status(404).json({ message: 'Student not found' });
    }

    let departmentDetails = null;
    if (student.department_name) {
      departmentDetails = await Department.findOne({ name: student.department_name }).select('head_of_department');
    }

    const academics = await Academic.find({ student_id: studentId }).sort({ semester: 1 });
    const fees = await Fee.find({ student_id: studentId }).sort({ payment_date: -1 });

    res.json({
      details: {
        ...student.toObject(),
        head_of_department: departmentDetails?.head_of_department || null
      },
      academics,
      fees,
    });

  } catch (error) {
    console.error("Get Student Details Error:", error);
    res.status(500).json({ message: 'Server Error', error: error.message });
  }
};

// Modified function without middleware dependency
export const getProfile = async (req, res) => {
  try {
    const { studentId } = req.params;

    if (!studentId) {
      return res.status(400).json({ message: 'Student ID is required' });
    }

    // Fetch only the specified fields for the profile
    const profile = await Student.findById(studentId).select(
      'email department_name current_year current_semester roll_number enrollment_number image first_name last_name'
    );

    if (!profile) {
      return res.status(404).json({ message: 'Student profile not found' });
    }

    // Return the profile data
    res.status(200).json(profile);

  } catch (error) {
    console.error("Get Profile Error:", error);
    res.status(500).json({ message: 'Server Error', error: error.message });
  }
};
export const resetPassword = async (req, res) => {
  try {
    const { oldPassword, newPassword, confirmPassword } = req.body;
    const { studentId } = req.params;

    // 1. Validation
    if (!oldPassword || !newPassword || !confirmPassword) {
      return res.status(400).json({ message: 'Please provide old password, new password, and confirmation' });
    }
    if (newPassword !== confirmPassword) {
      return res.status(400).json({ message: 'New passwords do not match' });
    }
    if (newPassword.length < 6) {
      return res.status(400).json({ message: 'Password must be at least 6 characters long' });
    }

    // 2. Find the student
    const student = await Student.findById(studentId);
    if (!student) {
      return res.status(404).json({ message: 'Student not found' });
    }

    // 3. Check if old password is correct
    const isMatch = await student.comparePassword(oldPassword);
    if (!isMatch) {
      return res.status(401).json({ message: 'Invalid old password' });
    }

    // 4. Set new password and save
    student.password = newPassword;
    await student.save(); // pre-save hook in the model will automatically hash the new password

    res.status(200).json({ message: 'Password changed successfully' });

  } catch (error) {
    console.error("Change Password Error:", error);
    res.status(500).json({ message: 'Server Error', error: error.message });
  }
};
export const getFeeDetails = async (req, res) => {
  try {
    const { studentId } = req.params;
    
    if (!studentId) {
      return res.status(400).json({ message: 'Student ID is required' });
    }

    // Build query object based on request query parameters
    const query = {
      student_id: studentId
    };
    if (req.query.payment_for) {
      query.payment_for = req.query.payment_for;
    }
    if (req.query.status) {
      query.status = req.query.status;
    }

    const feeDetails = await Fee.find(query);

    if (!feeDetails || feeDetails.length === 0) {
      return res.status(404).json({
        message: "No fee details found for the specified criteria"
      });
    }

    res.status(200).json(feeDetails);
  } catch (error) {
    console.error("Error fetching fee details:", error);
    res.status(500).json({
      message: "Internal server error"
    });
  }
};
export const getResultDetails = async (req, res) => {
  try {
    const { studentId } = req.params;

    // Find all academic records for the student (one document per semester)
    const academicRecords = await Academic.find({ student_id: studentId }).sort({ semester: 1 });

    if (!academicRecords || academicRecords.length === 0) {
      return res.status(404).json({ message: 'Result not found' });
    }

    // Return the array of semester academic documents
    res.status(200).json(academicRecords);
  } catch (error) {
    console.error("Error fetching result details:", error);
    res.status(500).json({
      message: "Internal server error"
    });
  }
};
//68f6421137e9c7ec56fb06b6