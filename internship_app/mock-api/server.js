const express = require("express");
const app = express();
const port = 3000;
app.use(express.json());


app.post("/api/mock", (req, res) => {
  console.log("Received QR Data:", req.body);
  const htmlResponse = `
    <html>
      <head>
        <style>
          body { background-color: lightblue; }
          h1 { color: navy; }
        </style>
      </head>
      <body>
        <h1>Hello, ${req.body.info}!</h1>
        <script>
          console.log('JavaScript is working!');
        </script>
      </body>
    </html>`;
  res.send(htmlResponse);
});

// Start the server
app.listen(port, () => {
  console.log(`Mock API server running at http://localhost:${port}`);
});
