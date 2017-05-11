#!/usr/bin/env node

const Promise = require('bluebird')
const fs = Promise.promisifyAll(require('fs'))
const axios = require('axios')
const path = require('path')
const assert = require('assert')
const parse = require('date-fns/parse')
const format = require('date-fns/format')

const accessToken = process.argv[2]
assert(accessToken, 'invalid accessToken')

const outputPath = './receipts'

async function download(accessToken) {
  try {
    await fs.mkdirAsync(outputPath)
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

    try {
      await fs.writeFileAsync(path.join(outputPath, filename), content)
    } catch (error) {
      Promise.reject('Failed to write the content')
    }

    // download images
    imageRegex = /\!\[.*\]\((https:\/\/qiita-image-store\.s3\.amazonaws\.com\/.+)\)/g
    while ((matches = imageRegex.exec(item.body))) {
      const imageURL = matches[1]
      try {
        const imageResponse = await axios.get(imageURL, {
          responseType: 'arraybuffer'
        })
        await fs.writeFileAsync(
          path.join(outputPath, path.basename(imageURL)),
          imageResponse.data
        )
      } catch (error) {
        Promise.reject('Failed to write the image')
      }
    }
  }
}

download(accessToken).catch(error => {
  console.log(error)
})
