//@ts-check
/**
 * This module serves as a sanity check for javascript files with typescript
 * annotations using TSDoc.
 *
 * The following should be true:
 *
 * - JSDoc should have syntax highlighting.
 * - Completion should be available.
 * - Type hints should come from example.d.ts
 * - The invocation of main should show virtual text indicating an error.
 */


/**
 *
 * @param {Example.TOptions} options
 * @returns {Example.TClosure}
 *
 */
function main(options) {


  const acceptable = new Set()
  options.aliases.map(item => {
    acceptable.add(item)
  })

  /**
    * @param {string} value
    * @returns {boolean}
    */
  function checkName(value) {
    return acceptable.has(value)
  }

  return { options, checkName }

}


/** This should indicate that the aliases are missing. */
main({ name: "SumGuy" })


/** @type {Example.TOptions} */
const miyamotoMusashiOptions = {
  name: "Miyamoto Musashi",
  aliases: [
    "Shinmen Bennosuke",
    "Shinmen Takezō",
    "Miyamoto Bennosuke",
    "Shinmen Musashi-no-Kami Fujiwara no Harunobu",
    "Niten Dōraku",
  ],
}

const mM = main(miyamotoMusashiOptions)

const isNot = "Baki Hanma"
if (!mM.checkName(isNot)) {
  console.log(`I am ${mM.options.name}, do not call me ${isNot}!`)
}
