import app from './src/app.js';
import dotenv from 'dotenv';
import connectDB from './src/config/db.js';

// Load environment variables
dotenv.config();

const PORT = process.env.PORT||3000;

// Connect to Database
try {
  connectDB()
} catch (error) {
  console.log(error)
}

app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
  });