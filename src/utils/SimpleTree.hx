package utils;

class SimpleTree<K,V>
{
    private var key :K;
    private var val :V;
    private var children :List<SimpleTree<K,V>>;

    // optional so the root doesn't have to have a key
    public function new(?k)
    {
        key = k;
        val = null;
        children = null;
    }

    // set a value at the specified path. create nodes as needed
    public function set(path :List<K>, val :V)
    {
        if( path.isEmpty() )
        {
            this.val = val;
            return;
        }

        if( children == null )
            children = new List<SimpleTree<K,V>>();
        var key = path.pop();
        var child = first(children, function(ii) return ii.key==key);
        if( child == null )
        {
            child = new SimpleTree<K,V>(key);
            children.add(child);
        }
        child.set(path, val);
    }

    // get the value at the specified path. return null if not found
    public function get(path :List<K>)
    {
        if( path.isEmpty() )
            return val;

        var key = path.pop();
        var child = first(children, function(ii) return ii.key==key);
        return if( child==null )
            null;
        else
            child.get(path);
    }

    // iterates over nodes, not lazy
    public function iterator()
    {
        var nodes = new List<SimpleTree<K,V>>();
        return nodes.iterator();
    }

    // iterates over values, not lazy
    public function getValues()
    {
        var nodes = new List<V>();
        return nodes.iterator();
    }

    // utility to find the first item that matches in a list
    private static function first<A>(it:Iterable<A>, f:A->Bool)
    {
        for( ii in it )
            if( f(ii) )
                return ii;
        return null;
    }
}
