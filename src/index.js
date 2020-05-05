import './style.scss';

import Elm from './Main.elm'

const storedData = localStorage.getItem('myapp-model');
const flags = storedData ? JSON.parse(storedData) : null;

const root = document.getElementById('main');
const app = Elm.Main.init({
    node: root,
    flags: flags
});

app.ports.setStorage.subscribe(function (state) {
    localStorage.setItem('myapp-model', JSON.stringify(state));
});

app.ports.printWindow.subscribe(function (state) {
    window.print();
})

app.ports.toggleModal.subscribe(function(state) {
    if (state === true) {
        document.body.style.position = 'fixed';
        document.body.style.top = `-${window.scrollY}px`;
    } else {
        const top = document.body.style.top;
        document.body.style.position = '';
        document.body.style.top = '';
        window.scrollTo(0, parseInt(scrollY || '0') * -1);        
    }
})