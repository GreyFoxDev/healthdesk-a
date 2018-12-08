// Class Template
// =============================================================

class MyModule {

  constructor () {

    this.init()

  }

  init () {

    // event handlers
    this.specificAction()
  }

  specificAction () {
    console.log('fired!')
  }
}

const MyModule = new MyModule()
