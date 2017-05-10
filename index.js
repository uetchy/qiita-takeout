const Promise = require('bluebird')
const fs = require('fs')
const axios = require('axios')
const path = require('path')
const parse = require('date-fns/parse')
const format = require('date-fns/format')
const mkdir = Promise.promisify(fs.mkdir)

const accessToken = process.env.QIITA_TOKEN
const outputPath = './receipts'

async function download(accessToken) {
  try {
    await mkdir(outputPath)
  } catch (error) {}

  const response = await axios.get(
    'https://qiita.com/api/v2/authenticated_user/items',
    {
      headers: {
        Authorization: `Bearer ${accessToken}`
      }
    }
  )

  for (item of response.data) {
    content = '---\n'
    content += `title: ${item.title}\n`
    content += `date: ${item.created_at}\n`
    content += '---\n\n'
    content += item.body
    filename = `${format(parse(item.created_at), 'YYYY-MM-DD')}-${item.id}.md`
    fs.writeFileSync(path.join(outputPath, filename), content)

    // download images
    imageRegex = /\!\[.*\]\((https:\/\/qiita-image-store\.s3\.amazonaws\.com\/.+)\)/g
    while ((matches = imageRegex.exec(item.body))) {
      const imageURL = matches[1]
      const imageResponse = await axios.get(imageURL, {
        responseType: 'arraybuffer'
      })
      fs.writeFileSync(path.join(outputPath, path.basename(imageURL)), imageResponse.data)
    }
  }
}

download(accessToken)
  .catch(error => {
    console.log(error)
  })