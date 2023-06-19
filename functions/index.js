
const nodemailer = require("nodemailer");

const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: "sam01rusher@gmail.com",
    pass: "maslow01sam",
  },
});
const mailOptions = {
  from: "sam01rusher@gmail.com",
  to: "samal200174@gmail.com",
  subject: "Hello from Firebase",
  text: "test.",
};
transporter.sendMail(mailOptions, (error, info) => {
  if (error) {
    console.error("Error sending email:", error);
  } else {
    console.log("Email sent:", info.response);
  }
});
