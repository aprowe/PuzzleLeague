########################
## Array Overrides
########################

## Function to remove an item from an array
Array.prototype.remove = (item)->
    if this.indexOf(item) > 0
        this.splice this.indexOf(item), 1
    return item

## Function to fill an array with undefined indexes
Array.prototype.fill = (w,h)->
    this[i] = [] for i in [0..w-1]
    this[i][h] = undefined for i in [0..w-1]


forall = (w,h,fn)->
    arr = []
    for i in [0..w-1]
        for j in [0..h-1]
            arr.push fn(i,j)

    return arr