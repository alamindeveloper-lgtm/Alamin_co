<!DOCTYPE html>
<html>
<head>
  <title>NorthBridge Bank</title>

  <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

  <style>
    body {
      margin: 0;
      font-family: Arial;
      background: #0b1220;
      color: white;
    }

    header {
      padding: 15px;
      background: #0f172a;
      text-align: center;
      border-bottom: 1px solid #22314d;
    }

    .container {
      padding: 20px;
      max-width: 900px;
      margin: auto;
    }

    .card {
      background: #111c33;
      padding: 16px;
      margin: 10px 0;
      border-radius: 12px;
      border: 1px solid #22314d;
    }

    input {
      width: 100%;
      padding: 10px;
      margin: 5px 0;
      border-radius: 6px;
      border: none;
    }

    button {
      width: 100%;
      padding: 10px;
      margin-top: 6px;
      background: #38bdf8;
      border: none;
      border-radius: 6px;
      font-weight: bold;
      cursor: pointer;
    }

    .balance {
      font-size: 34px;
      color: #22c55e;
    }

    .tx {
      font-size: 13px;
      border-bottom: 1px solid #22314d;
      padding: 5px 0;
    }

    #dashboard {
      display: none;
    }
  </style>
</head>

<body>

<header>
  <h2>NorthBridge Digital Bank</h2>
</header>

<div class="container">

<!-- AUTH -->
<div id="auth">
  <div class="card">
    <h3>Login / Register</h3>
    <input id="email" placeholder="Email">
    <input id="password" type="password" placeholder="Password">
    <button onclick="signup()">Create Account</button>
    <button onclick="login()">Login</button>
  </div>
</div>

<!-- DASHBOARD -->
<div id="dashboard">

  <div class="card">
    <h3>Balance</h3>
    <div class="balance" id="balance">$0</div>
  </div>

  <div class="card">
    <h3>Deposit / Withdraw</h3>
    <button onclick="deposit()">+ $100 Deposit</button>
    <button onclick="withdraw()">- $50 Withdraw</button>
  </div>

  <div class="card">
    <h3>Transfer</h3>
    <input id="receiver" placeholder="Receiver Email">
    <input id="amount" type="number" placeholder="Amount">
    <button onclick="transfer()">Send</button>
  </div>

  <div class="card">
    <h3>Transactions</h3>
    <div id="transactions"></div>
  </div>

  <div class="card">
    <h3>Analytics</h3>
    <canvas id="chart"></canvas>
  </div>

  <div class="card">
    <button onclick="logout()">Logout</button>
  </div>

</div>

</div>

<!-- FIREBASE -->
<script src="https://www.gstatic.com/firebasejs/10.7.1/firebase-app.js"></script>
<script src="https://www.gstatic.com/firebasejs/10.7.1/firebase-auth.js"></script>
<script src="https://www.gstatic.com/firebasejs/10.7.1/firebase-firestore.js"></script>

<script>
const firebaseConfig = {
  // Import the functions you need from the SDKs you need
import { initializeApp } from "firebase/app";
// TODO: Add SDKs for Firebase products that you want to use
// https://firebase.google.com/docs/web/setup#available-libraries

// Your web app's Firebase configuration
const firebaseConfig = {
  apiKey: "AIzaSyAD2VoJ0RHBolrFISg1V04uU_yBJNa2vpI",
  authDomain: "goldman-sachs-bank.firebaseapp.com",
  projectId: "goldman-sachs-bank",
  storageBucket: "goldman-sachs-bank.firebasestorage.app",
  messagingSenderId: "977806401982",
  appId: "1:977806401982:web:60fc15f473080c089e59ef"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);

firebase.initializeApp(firebaseConfig);

const auth = firebase.auth();
const db = firebase.firestore();

let userData = null;

// SIGNUP
function signup() {
  let email = email.value;
  let pass = password.value;

  let pin = prompt("Create 4-digit PIN");

  auth.createUserWithEmailAndPassword(email, pass)
  .then(userCred => {
    let user = userCred.user;

    db.collection("users").doc(user.uid).set({
      email,
      balance: 1000,
      pin,
      transactions: ["Account created $1000"],
      history: [1000]
    });

    alert("Account created");
  });
}

// LOGIN
function login() {
  let email = email.value;
  let pass = password.value;

  auth.signInWithEmailAndPassword(email, pass)
  .then(userCred => {
    let user = userCred.user;

    let pin = prompt("Enter PIN");

    db.collection("users").doc(user.uid).get()
    .then(doc => {
      userData = doc.data();

      if (pin !== userData.pin) {
        alert("Wrong PIN");
        auth.signOut();
        return;
      }

      document.getElementById("auth").style.display = "none";
      document.getElementById("dashboard").style.display = "block";

      render();
    });
  });
}

// RENDER
function render() {
  document.getElementById("balance").innerText = "$" + userData.balance;

  let html = "";
  userData.transactions.forEach(t => {
    html += `<div class="tx">${t}</div>`;
  });

  document.getElementById("transactions").innerHTML = html;

  chart();
}

// SAVE
function save() {
  db.collection("users").doc(auth.currentUser.uid).update(userData);
}

// DEPOSIT
function deposit() {
  let bal = userData.balance + 100;
  userData.balance = bal;
  userData.transactions.push("Deposit $100");
  userData.history.push(bal);

  save();
  render();
}

// WITHDRAW
function withdraw() {
  if (userData.balance < 50) return alert("Low balance");

  let bal = userData.balance - 50;
  userData.balance = bal;
  userData.transactions.push("Withdraw $50");
  userData.history.push(bal);

  save();
  render();
}

// TRANSFER
function transfer() {
  let email = receiver.value;
  let amount = Number(amount.value);

  if (userData.balance < amount) return alert("Not enough balance");

  let bal = userData.balance - amount;
  userData.balance = bal;

  userData.transactions.push("Sent $" + amount + " to " + email);
  userData.history.push(bal);

  save();
  render();
}

// LOGOUT
function logout() {
  auth.signOut();
  location.reload();
}

// CHART
function chart() {
  new Chart(document.getElementById("chart"), {
    type: "line",
    data: {
      labels: userData.history.map((_, i) => i + 1),
      datasets: [{
        label: "Balance",
        data: userData.history,
        borderColor: "#22c55e",
        fill: false
      }]
    }
  });
}
</script>

</body>
</html>
