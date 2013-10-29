/**
 * Created by Youri GICQUEL
 */

package {
import aerys.minko.render.geometry.Geometry;
import aerys.minko.render.geometry.stream.IVertexStream;
import aerys.minko.render.geometry.stream.IndexStream;
import aerys.minko.render.geometry.stream.StreamUsage;
import aerys.minko.render.geometry.stream.VertexStream;
import aerys.minko.render.geometry.stream.format.VertexComponent;
import aerys.minko.render.geometry.stream.format.VertexFormat;
import aerys.minko.render.material.Material;
import aerys.minko.render.material.basic.BasicMaterial;
import aerys.minko.render.material.phong.PhongEffect;
import aerys.minko.scene.node.Group;
import aerys.minko.scene.node.Mesh;
import aerys.minko.type.enum.TriangleCulling;



import flash.geom.Vector3D;

import flash.utils.ByteArray;
import flash.utils.Endian;

public final class STLParser {

    public var header:String = new String();

    private var vertex:Vector.<Number> = new <Number>[];
    private var index:Vector.<uint> = new <uint>[];

    private var _p1:Vector3D = new Vector3D();
    private var _p2:Vector3D = new Vector3D();
    private var _p3:Vector3D = new Vector3D();

    private var _normal:Vector3D = new Vector3D();

    private var _cpt:int = 0;

    public function STLParser() {
    }

    public function parsing(tab:ByteArray):Group {
        tab.endian = Endian.LITTLE_ENDIAN;
        tab.position = 0;
        header = tab.readUTFBytes(80);
        tab.readByte();
        if (tab.position < 84)
            tab.position = 84;
        while (tab.bytesAvailable > 0) {
            tab.position += 12;
            parsVert(tab);
            parsEnd(tab);
        }
        return (generateMesh());
    }

    private static function parsEnd(tab:ByteArray):void {
        tab.position += 2;
    }

    private function generateNormal():void {
        _normal.x = (_p2.y - _p1.y) * (_p3.z - _p1.z) - (_p2.z - _p1.z) * (_p3.y - _p1.y);
        _normal.y = (_p2.z - _p1.z) * (_p3.x - _p1.x) - (_p2.x - _p1.x) * (_p3.z - _p1.z);
        _normal.z = (_p2.x - _p1.x) * (_p3.y - _p1.y) - (_p2.y - _p1.y) * (_p3.x - _p1.x);
        if (_normal.x > 1)
            _normal.x = 1;
        if (_normal.y > 1)
            _normal.y = 1;
        if (_normal.z > 1)
            _normal.z = 1;
    }

    private function parsVert(tab:ByteArray):void {
        _p1.x = tab.readFloat();
        _p1.y = tab.readFloat();
        _p1.z = tab.readFloat();
        _p2.x = tab.readFloat();
        _p2.y = tab.readFloat();
        _p2.z = tab.readFloat();
        _p3.x = tab.readFloat();
        _p3.y = tab.readFloat();
        _p3.z = tab.readFloat();
        generateNormal();

        vertex.push(_p1.x, _p1.y, _p1.z);
        vertex.push(_normal.x, _normal.y, _normal.z);
        index.push(_cpt);
        _cpt++;

        vertex.push(_p2.x, _p2.y, _p2.z);
        vertex.push(_normal.x, _normal.y, _normal.z);
        index.push(_cpt);
        _cpt++;

        vertex.push(_p3.x, _p3.y, _p3.z);
        vertex.push(_normal.x, _normal.y, _normal.z);
        index.push(_cpt);
        _cpt++;
    }

    internal function generateMesh():Group {
        var group:Group = new Group();

        var mesh:Mesh;
        var geom:Geometry;
        var material:Material;

        // générer l'indexStream
        var indexStream:IndexStream = IndexStream.fromVector(StreamUsage.DYNAMIC, index);

        var verticesStream:Vector.<IVertexStream> = new <IVertexStream>[];

        // générer le vertex buffer
        var format:VertexFormat = new VertexFormat();
        format.addComponent(VertexComponent.XYZ);
        format.addComponent(VertexComponent.NORMAL);

        // ajout des composants format
        var vertexStream:VertexStream = VertexStream.fromVector(StreamUsage.DYNAMIC, format, vertex);
        verticesStream.push(vertexStream);

        geom = new Geometry(verticesStream, indexStream);
        material = new BasicMaterial(
                {diffuseColor: 0xEEEEEEFF,
                    triangleCulling: TriangleCulling.NONE},
                new PhongEffect()
        );
        mesh = new Mesh(geom, material);
        group.addChild(mesh);
        return group;
    }

}
}
