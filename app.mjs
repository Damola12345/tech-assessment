import express from 'express';

const app = express();
const port = 3000;

app.get('/', (req, res) => {
  res.send('Welcome to ToyeGlobal');
});

if (process.argv[1] === new URL(import.meta.url).pathname) {
  app.listen(port, () => {
    console.log(`App listening at http://localhost:${port}`);
  });
}

export default app;
