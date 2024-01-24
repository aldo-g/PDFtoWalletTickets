const axios = require('axios');

async function generateImage() {
    try {
        const response = await axios.post('https://api.deepai.org/api/text2img', {
            text: 'A scenic beach with a sunset in the background.'
        }, {
            headers: {
                'Api-Key': 'your-api-key'
            }
        });

        console.log(response.data);
    } catch (error) {
        console.error(error);
    }
}

generateImage();