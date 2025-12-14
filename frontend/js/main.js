window.addEventListener('DOMContentLoaded', (event) => {
    getVisitCount();
});

const functionApiUrl = 'https://visitorcount-erdbh8gseqete9gp.swedencentral-01.azurewebsites.net/api/getvisitorcount';

const getVisitCount = async () => {
    fetch(functionApiUrl)
    .then(response => {
        return response.text() 
    })
    .then(rawCount => {
        console.log('Website called function API. Raw count received:', rawCount);
        
        document.getElementById('Counter').innerText = rawCount;
        
    }).catch(err => {
        console.log('Error calling function API:', err);
    });
}