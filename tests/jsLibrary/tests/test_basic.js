///////////////////////////////////////////////////////////////////////////
// Copyright 2020 Roku, Inc.
//
//Licensed under the Apache License, Version 2.0 (the "License")
// you may not use this file except in compliance with the License.
//You may obtain a copy of the License at
//    http://www.apache.org/licenses/LICENSE-2.0
//
//Unless required by applicable law or agreed to in writing, software
//distributed under the License is distributed on an "AS IS" BASIS,
//WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//See the License for the specific language governing permissions and
//limitations under the License.
//////////////////////////////////////////////////////////////////////////

const rokuLibrary = require('../library/rokuLibrary')
const { expect } = require('chai')
const { spawn } = require('child_process')

const childProcess = spawn('../bin/RokuWebDriver_mac')

let library

const buttons = [
  'Initialize',
  'Initialize Error',
  'Identify User',
  'Reset User',
  'Get All Features',
  'Get All Variables',
  'Get Variable',
  'Get Variable Value',
  'Track Event',
]

let currentButtonIndex = 0
let isInitialized = false

const pressButton = async (buttonName) => {
  const buttonIndex = buttons.indexOf(buttonName)
  if (buttonIndex === -1) {
    console.log(`Button "${buttonName}" not found`)
    return
  }

  if (buttonIndex < currentButtonIndex) {
    for (let i = 0; i < currentButtonIndex - buttonIndex; i++) {
      await library.sendKey('up')
    }
  } else {
    for (let i = 0; i < buttonIndex - currentButtonIndex; i++) {
      await library.sendKey('down')
    }
  }

  currentButtonIndex = buttonIndex

  await library.sendKey('select')
  await library.sleep(500)
}

const getTextFromElement = async (id) => {
  const element = await library.getElement({
    elementData: [{ using: 'attr', attribute: 'name', value: id }],
  })
  const text = library.getAttribute(element, 'text')
  return text
}

const initializeDevCycle = async () => {
  if (isInitialized) {
    return
  }
  await pressButton('Initialize')
  isInitialized = true
}

describe('DevCycle Tests', () => {
  before(async function () {
    const ip = process.env.ROKU_IP
    const password = process.env.ROKU_PASSWORD
    if (!ip || !password) {
      throw new Error(
        'ROKU_IP and ROKU_PASSWORD must be set, run the script `setup_tests.sh` to set them'
      )
    }
    this.timeout(50000)
    library = new rokuLibrary.Library(ip)
    await library.sideLoad('../sample/channel.zip', 'rokudev', password)
  })

  it('should launch the channel', async function () {
    this.timeout(15000)
    await library.verifyIsChannelLoaded('dev')
  })

  it('Check if DevCycle test app has started', async function () {
    this.timeout(30000)
    const res = await library.verifyIsScreenLoaded({
      elementData: [{ using: 'text', value: 'DevCycle Test App!' }],
    })
    expect(res).to.equal(true)
  })

  describe('Initialize Error Tests', () => {
    it('Press Initialize Error button and verify values', async function () {
      this.timeout(30000) // Increased timeout to allow for initialization

      await pressButton('Initialize Error')

      const buttonPressedLabel = await getTextFromElement('buttonPressedLabel')
      expect(buttonPressedLabel).to.include('Initialize Error')

      // Verify jsonVar text
      const jsonVarText = await getTextFromElement('jsonVar')
      expect(jsonVarText).to.include('No Variables Data')

      // Verify numVar text
      const numVarText = await getTextFromElement('numVar')
      expect(numVarText).to.include('No Variables Data')

      // Verify stringVar text
      const stringVarText = await getTextFromElement('stringVar')
      expect(stringVarText).to.include('No Variables Data')

      // Verify booleanSquare color
      const booleanSquareElement = await library.getElement({
        elementData: [{ using: 'attr', attribute: 'name', value: 'booleanSquare' }],
      })
      const booleanSquareColor = library.getAttribute(booleanSquareElement, 'color')
      // check if its blue
      expect(booleanSquareColor).to.equal('#0000ffff')
    })
  })

  describe('Initialize Tests', () => {
    it('Press Initialize button and verify values', async function () {
      this.timeout(30000) // Increased timeout to allow for initialization

      // Press the Initialize button
      await initializeDevCycle()

      const buttonPressedLabel = await getTextFromElement('buttonPressedLabel')
      expect(buttonPressedLabel).to.include('Initialize')

      // Verify jsonVar text
      const jsonVarText = await getTextFromElement('jsonVar')
      expect(jsonVarText).to.include('{"key":"value1"}')

      // Verify numVar text
      const numVarText = await getTextFromElement('numVar')
      expect(numVarText).to.include('100')

      // Verify stringVar text
      const stringVarText = await getTextFromElement('stringVar')
      expect(stringVarText).to.include('string-1')

      // Verify booleanSquare color
      const booleanSquareElement = await library.getElement({
        elementData: [{ using: 'attr', attribute: 'name', value: 'booleanSquare' }],
      })
      const booleanSquareColor = library.getAttribute(booleanSquareElement, 'color')
      // check if its green
      expect(booleanSquareColor).to.equal('#00ff00ff')
    })
  })

  describe('IdentifyUser Tests', () => {
    it('Press Identify User button and verify values', async function () {
      this.timeout(30000) // Increased timeout to allow for initialization
      // Press the Identify User button
      await initializeDevCycle()
      await pressButton('Identify User')

      const buttonPressedLabel = await getTextFromElement('buttonPressedLabel')
      expect(buttonPressedLabel).to.include('Identify User')

      // Verify jsonVar text
      const jsonVarText = await getTextFromElement('jsonVar')
      expect(jsonVarText).to.include('{"key":"value2"}')

      // Verify numVar text
      const numVarText = await getTextFromElement('numVar')
      expect(numVarText).to.include('50')

      // Verify stringVar text
      const stringVarText = await getTextFromElement('stringVar')
      expect(stringVarText).to.include('string-2')

      // Verify booleanSquare color
      const booleanSquareElement = await library.getElement({
        elementData: [{ using: 'attr', attribute: 'name', value: 'booleanSquare' }],
      })
      const booleanSquareColor = library.getAttribute(booleanSquareElement, 'color')
      // check if its green
      expect(booleanSquareColor).to.equal('#00ff00ff')
    })
  })

  describe('ResetUser Tests', () => {
    it('Press Reset User button and verify values', async function () {
      this.timeout(30000) // Increased timeout to allow for initialization
      // Press the Identify User button
      await initializeDevCycle()
      await pressButton('Reset User')

      const buttonPressedLabel = await getTextFromElement('buttonPressedLabel')
      expect(buttonPressedLabel).to.include('Reset User')

      // Verify jsonVar text
      const jsonVarText = await getTextFromElement('jsonVar')
      expect(jsonVarText).to.include('{}')

      // Verify numVar text
      const numVarText = await getTextFromElement('numVar')
      expect(numVarText).to.include('0')

      // Verify stringVar text
      const stringVarText = await getTextFromElement('stringVar')
      expect(stringVarText).to.include('stringy')

      // Verify booleanSquare color
      const booleanSquareElement = await library.getElement({
        elementData: [{ using: 'attr', attribute: 'name', value: 'booleanSquare' }],
      })
      const booleanSquareColor = library.getAttribute(booleanSquareElement, 'color')
      // check if its red
      expect(booleanSquareColor).to.equal('#ff0000ff')
    })
  })

  describe('GetAllFeatures Tests', () => {
    it('should get allfeatures ', async function () {
      this.timeout(50000)
      await initializeDevCycle()
      await pressButton('Get All Features')

      // Verify jsonVar text
      const resultLabel = await getTextFromElement('resultLabel')

      const buttonPressedLabel = await getTextFromElement('buttonPressedLabel')
      expect(buttonPressedLabel).to.include('Get All Features')
      expect(resultLabel).to.include('Features:')
      expect(resultLabel).to.not.equal('Features: null')
    })
  })

  describe('GetAllVariables Tests', () => {
    it('should get allvariables ', async function () {
      this.timeout(50000)
      await initializeDevCycle()
      await pressButton('Get All Variables')

      // Verify jsonVar text
      const resultLabel = await getTextFromElement('resultLabel')

      const buttonPressedLabel = await getTextFromElement('buttonPressedLabel')
      expect(buttonPressedLabel).to.include('Get All Variables')
      expect(resultLabel).to.include('Variables:')
      expect(resultLabel).to.not.equal('Variables: null')
    })
  })

  describe('GetVariable Tests', () => {
    it('should get the variable values with default value', async function () {
      this.timeout(30000)
      await pressButton('Reset User')
      await pressButton('Get Variable')

      const buttonPressedLabel = await getTextFromElement('buttonPressedLabel')
      expect(buttonPressedLabel).to.include('Get Variable')

      const resultLabel = await getTextFromElement('resultLabel')
      expect(resultLabel).to.include('Variable:')
      expect(resultLabel).to.include('default value')
    })

    it('should get the variable values', async function () {
      this.timeout(30000)
      await initializeDevCycle()
      await pressButton('Identify User')
      await pressButton('Get Variable')

      const buttonPressedLabel = await getTextFromElement('buttonPressedLabel')
      expect(buttonPressedLabel).to.include('Get Variable')
      const resultLabel = await getTextFromElement('resultLabel')
      expect(resultLabel).to.include('Variable:')
      expect(resultLabel).to.include('Bonjour')
    })
  })
  describe('GetVariableValue Tests', () => {
    it('should get the default value of the variable values', async function () {
      this.timeout(30000)
      await pressButton('Reset User')
      await pressButton('Get Variable Value')

      const buttonPressedLabel = await getTextFromElement('buttonPressedLabel')
      expect(buttonPressedLabel).to.include('Get Variable Value')

      const resultLabel = await getTextFromElement('resultLabel')
      expect(resultLabel).to.include('Variable Value:')
      expect(resultLabel).to.include('default value')
    })

    it('should get the variable values', async function () {
      this.timeout(30000)
      await initializeDevCycle()
      await pressButton('Identify User')
      await pressButton('Get Variable Value')

      const buttonPressedLabel = await getTextFromElement('buttonPressedLabel')
      expect(buttonPressedLabel).to.include('Get Variable Value')

      const resultLabel = await getTextFromElement('resultLabel')
      expect(resultLabel).to.include('Variable Value:')
      expect(resultLabel).to.include('Bonjour')
    })
  })

  after(async () => {
    await library.close()
    childProcess.kill()
  })
})
