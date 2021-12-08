#!/usr/bin/nodejs
//import * as esl from "modesl"; // For Typescript 
const esl = require("modesl");   // For Javascript

const ESL_HOST="localhost";  // Freeswitch host
const ESL_PORT=8021;  // ESL Port 
const ESL_PASSWORD="ClueCon"; // ESL Password

console.log("Connecting with ESL");
var eslConn;
eslConn = new esl.Connection(ESL_HOST, ESL_PORT, ESL_PASSWORD, function () {
  // @ts-ignore
  eslConn.subscribe();
});

eslConn.on("error", (e) => {
  console.error("[ESL] connection failed");
  console.error(e);
  process.exit(-1);
});

eslConn.on("esl::end", (e) => {
  console.log("[ESL] connection closed");
  console.error(e);
  process.exit(-1);
});

eslConn.on("esl::ready", () => {
  console.log("started FS");
  console.log("[ESL] connected");
});
eslConn.on("esl::event::CUSTOM::*", async (evt) => {
  console.log("Received CUSTOM event",evt);
});
eslConn.on("esl::event::DTMF::*", async (evt) => {
  console.log("Received DTMF event",evt);
});
