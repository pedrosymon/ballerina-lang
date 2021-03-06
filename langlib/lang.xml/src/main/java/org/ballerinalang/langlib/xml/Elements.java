/*
 * Copyright (c) 2017, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
 *
 * WSO2 Inc. licenses this file to you under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 **/

package org.ballerinalang.langlib.xml;

import org.ballerinalang.jvm.api.values.BString;
import org.ballerinalang.jvm.api.values.BXML;
import org.ballerinalang.jvm.scheduling.Strand;
import org.ballerinalang.jvm.util.exceptions.BLangExceptionHelper;
import org.ballerinalang.jvm.values.IteratorValue;
import org.ballerinalang.jvm.values.XMLSequence;
import org.ballerinalang.jvm.values.XMLValue;
import org.ballerinalang.model.types.TypeKind;
import org.ballerinalang.natives.annotations.BallerinaFunction;
import org.ballerinalang.natives.annotations.ReturnType;

import java.util.ArrayList;
import java.util.List;

import static org.ballerinalang.util.BLangCompilerConstants.XML_VERSION;

/**
 * Get all the elements-type items of a xml.
 * 
 * @since 0.88
 */
@BallerinaFunction(
        orgName = "ballerina", packageName = "lang.xml", version = XML_VERSION,
        functionName = "elements",
        returnType = {@ReturnType(type = TypeKind.XML)},
        isPublic = true
)
public class Elements {

    private static final String OPERATION = "get elements from xml";

    public static XMLValue elements(Strand strand, XMLValue xml, Object name) {
        try {
            if (name instanceof BString) {
                return (XMLValue) xml.elements(((BString) name).getValue());
            }
            return (XMLValue) xml.elements();
        } catch (Throwable e) {
            BLangExceptionHelper.handleXMLException(OPERATION, e);
        }

        return null;
    }

    private static XMLValue generateCodePointSequence(XMLValue value) {
        List<BXML> list = new ArrayList<>();
        IteratorValue bIterator = value.getIterator();
        while (bIterator.hasNext()) {
            list.add((XMLValue) bIterator.next());
        }
        return new XMLSequence(list);
    }
}
