import { useState } from 'react';
import { HttpCoinbase_backend } from 'declarations/HttpCoinbase_backend';

function App() {
  const [dataHistoryList, setDataHistoryList] = useState([]);

  function fetchDataHistory() {
    HttpCoinbase_backend.dataHistory().then((dataHistory) => {
      setDataHistoryList(dataHistory);
    });
  }

  return (
    <main>
      <img src="/logo2.svg" alt="DFINITY logo" />
      
      <button onClick={fetchDataHistory}>Show Data History</button>
      <section id="data-history-list">
        {dataHistoryList.length > 0 ? (
          <ul>
            {dataHistoryList.map((item, index) => (
              <li key={index}>{item}</li>
            ))}
          </ul>
        ) : (
          <p>No Data Yet</p>
        )}
      </section>
    </main>
  );
}

export default App;
