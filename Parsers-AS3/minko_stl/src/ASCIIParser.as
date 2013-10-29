/**
 * Created by Youri GICQUEL
 */
package {

import aerys.minko.render.geometry.Geometry;
import aerys.minko.render.geometry.GeometrySanitizer;
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

public class ASCIIParser {
    
    private var index:Vector.<uint> = new <uint>[];
    private var vertex:Vector.<Number> = new <Number>[];

    private var _tmp:String;
    private var _p1:Vector3D = new Vector3D();
    private var _p2:Vector3D = new Vector3D();
    private var _p3:Vector3D = new Vector3D();
    private var _normal:Vector3D = new Vector3D();
    private var _index:ByteArray = new ByteArray();
    private var _vertex:ByteArray = new ByteArray();


    public function ASCIIParser() {
    }

    private function newtab(tmp:String):String {
        var i:int = 0;

        while ((tmp.charAt(i) >= '0' && tmp.charAt(i) <= '9')
                || tmp.charAt(i) == '.'
                || tmp.charAt(i) == '-')
            i++;
        tmp = tmp.slice(++i, tmp.length);
        return (tmp);
    }

    private function epurMesh():void {
        var i:int = 0;

        while (i < index.length) {
            _index.writeInt(index[i]);
            i++;
        }
        i = 0;
        while (i < vertex.length) {
            _vertex.writeFloat(vertex[i]);
            i++;
        }
        _index.position = 0;
        _vertex.position = 0;
    }

    public function parsing(tab:String):Group {
        var pos:int = 0;
        var pos2:int = 0;
        var old:int = 0;
        var cpt:int = 1;

        while (pos < tab.length && pos2 < tab.length)
        {
            if ((pos2 = tab.indexOf("vertex", pos2)) > -1){
                addPoint(pos2, tab, 1);
                pos2++;
                pos2 = tab.indexOf("vertex", pos2);
                addPoint(pos2, tab, 2);
                pos2++;
                pos2 = tab.indexOf("vertex", pos2);
                addPoint(pos2, tab, 3);
                generateNormal();
                while (cpt < 4){
                    exist(cpt);
                    normal();
                    cpt++;
                }
                while(cpt < 7){
                    index.push(old);
                    old++;
                    cpt++;
                }
                cpt = 1;
            }
            else{
                epurMesh();
                GeometrySanitizer.removeDuplicatedVertices(_vertex, _index);
                return (generateMesh());
            }
            pos2++;
            pos++;
        }
        return null;
    }

    private function normal():void {
        vertex.push(_normal.x);
        vertex.push(_normal.y);
        vertex.push(_normal.z);
    }

    private function generateNormal():void {
        _normal.x = (_p2.y - _p1.y) * (_p3.z - _p1.z) - (_p2.z - _p1.z) * (_p3.y - _p1.y);
        _normal.y = (_p2.z - _p1.z) * (_p3.x - _p1.x) - (_p2.x - _p1.x) * (_p3.z - _p1.z);
        _normal.z = (_p2.x - _p1.x) * (_p3.y - _p1.y) - (_p2.y - _p1.y) * (_p3.x - _p1.x);
    }

    private function exist(val:int):void {
        if (val == 1){
            vertex.push(_p1.x);
            vertex.push(_p1.y);
            vertex.push(_p1.z);
        }
        else if (val == 2){
            vertex.push(_p2.x);
            vertex.push(_p2.y);
            vertex.push(_p2.z);
        }
        else if (val == 3){
            vertex.push(_p3.x);
            vertex.push(_p3.y);
            vertex.push(_p3.z);
        }

    }

    private function addPoint(pos:int, tab:String, val:int):void {
        var i:int;

        i = pos;
        while (i < tab.length && tab.charAt(i) != '\n') i++;
        _tmp = tab.slice(int(pos + 7), i);

        if (val == 1){
            _p1.x = (parseFloat(_tmp));
            _tmp = newtab(_tmp);
            _p1.y = (parseFloat(_tmp));
            _tmp = newtab(_tmp);
            _p1.z = (parseFloat(_tmp));
            _tmp = newtab(_tmp);
        }
        else if (val == 2){
            _p2.x = (parseFloat(_tmp));
            _tmp = newtab(_tmp);
            _p2.y = (parseFloat(_tmp));
            _tmp = newtab(_tmp);
            _p2.z = (parseFloat(_tmp));
            _tmp = newtab(_tmp);
        }
        else{
            _p3.x = (parseFloat(_tmp));
            _tmp = newtab(_tmp);
            _p3.y = (parseFloat(_tmp));
            _tmp = newtab(_tmp);
            _p3.z = (parseFloat(_tmp));
            _tmp = newtab(_tmp);
        }
    }

    private function generateMesh():Group {
        var group : Group = new Group();

        var mesh:Mesh;
        var geom : Geometry;
        var material : Material;

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
                {diffuseColor:0xEEEEEEFF,
                    triangleCulling:TriangleCulling.NONE},
                new PhongEffect()
        );
        mesh = new Mesh(geom, material);

        group.addChild(mesh);
        return group;
    }
}
}
