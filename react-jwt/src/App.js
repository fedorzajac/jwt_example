import {React, useState} from 'react';
// import logo from './logo.svg';
import './App.css';

function App() {
  const [token, setToken] = useState(localStorage.getItem('token'));

  function login() {
    // Send login request to server
    console.log('logging in...');
    const url = 'http://localhost:4567/login'
    const data = {username: 'admin', password: 'password'}
    fetch(url, {
      method: 'POST',
          headers: {
        'Content-Type': 'application/json'
        //'Token': loginToken
        // 'Content-Type': 'application/x-www-form-urlencoded',
      },
      // redirect: 'follow', // manual, *follow, error
      // referrerPolicy: 'no-referrer', // no-referrer, *no-referrer-when-downgrade, origin, origin-when-cross-origin, same-origin, strict-origin, strict-origin-when-cross-origin, unsafe-url
      body: JSON.stringify(data)
    }).then((response) => response.json())
      .then((data) => {
        console.log(data)
        // ...
        // Save token to localStorage
        localStorage.setItem('token', data.token);
        setToken(data.token);
      });
  }

  function logout() {
    // Remove token from localStorage
    localStorage.removeItem('token');
    setToken(null);
  }

  function getProtectedData() {
    fetch('http://localhost:4567/protected', {
      headers: {
        Authorization: `Bearer ${token}`,
      },
    })
      .then((response) => response.json())
      .then((data) => console.log(data))
      .catch((error) => console.error(error));
  }

  return (
    <div>
      {token ? (
        <button onClick={logout}>Logout</button>
      ) : (
        <button onClick={login}>Login</button>
      )}
      <button onClick={getProtectedData}>Get Protected Data</button>
    </div>
  );
}

export default App;
