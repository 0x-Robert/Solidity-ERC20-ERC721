const { ThirdwebStorage } = require("@thirdweb-dev/storage");
const fs = require("fs");
const express = require("express");
const fileUpload = require("express-fileupload");
const app = express();

const port = 8999;
const Web3 = require("web3");

app.use(fileUpload());

app.post("/upload", (req, res) => {
  if (!req.files || Object.keys(req.files).length === 0) {
    return res.status(400).send("No files were uploaded.");
  }
  //console.log("req.files",req)
  console.log("--- ,req.files.files.file1[name])", req.files["file1"]["name"]);
  console.log("--- ,req.files.files.file1[name])", req.files["file1"]);

  //console.log("** req.files.files ",req.files.files[0])
  const storage = new ThirdwebStorage();
  //console.log(req.files)
  //let uploadFile = `/upload/${req.files.filename}`

  (async () => {
    const upload = await storage.upload(
      fs.readFileSync(req.files["file1"]["name"])
    );
    console.log(`Gateway URL - ${storage.resolveScheme(upload)}`);
    res.send(`${storage.resolveScheme(upload)}`);
  })();
});

app.listen(3003, () => {
  console.log("Server listening on port 3003");
});
