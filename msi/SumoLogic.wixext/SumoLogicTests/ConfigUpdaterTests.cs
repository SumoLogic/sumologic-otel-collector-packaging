using Microsoft.VisualStudio.TestTools.UnitTesting;
using SumoLogic.wixext;
using System;
using System.IO;
using YamlDotNet.RepresentationModel;

namespace SumoLogicTests
{
    [TestClass]
    public class ConfigUpdaterTests
    {
        readonly string testDataPath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "TestData");

        public void InstallationTokenAssertions(Config config, StreamReader sr)
        {
            YamlStream ys = new YamlStream();
            ys.Load(sr);
            YamlMappingNode root = (YamlMappingNode)ys.Documents[0].RootNode;

            Assert.IsTrue(root.Children.ContainsKey("extensions"));
            Assert.AreEqual(YamlNodeType.Mapping, root.Children["extensions"].NodeType);
            var extensions = (YamlMappingNode)root.Children["extensions"];

            Assert.IsTrue(extensions.Children.ContainsKey("sumologic"));
            Assert.AreEqual(YamlNodeType.Mapping, extensions.Children["sumologic"].NodeType);
            var sumologic = (YamlMappingNode)extensions.Children["sumologic"];

            Assert.IsTrue(sumologic.Children.ContainsKey("installation_token"));
            Assert.AreEqual(YamlNodeType.Scalar, sumologic.Children["installation_token"].NodeType);
            Assert.AreEqual(config.InstallationToken, sumologic.Children["installation_token"].ToString());

            if (config.Ephemeral)
            {
                Assert.IsTrue(sumologic.Children.ContainsKey("ephemeral"));
                Assert.AreEqual(YamlNodeType.Scalar, sumologic.Children["ephemeral"].NodeType);
                Assert.AreEqual("true", sumologic.Children["ephemeral"].ToString());
            }
            else
            {
                Assert.IsFalse(sumologic.Children.ContainsKey("ephemeral"));
            }

            Assert.IsTrue(sumologic.Children.ContainsKey("collector_fields"));
            Assert.AreEqual(YamlNodeType.Mapping, sumologic.Children["collector_fields"].NodeType);
            var collectorFields = (YamlMappingNode)sumologic.Children["collector_fields"];

            Assert.IsTrue(collectorFields.Children.ContainsKey("foo"));
            Assert.IsTrue(collectorFields.Children.ContainsKey("baz"));
            Assert.IsTrue(collectorFields.Children.ContainsKey("xaz"));
            Assert.AreEqual(YamlNodeType.Scalar, collectorFields.Children["foo"].NodeType);
            Assert.AreEqual(YamlNodeType.Scalar, collectorFields.Children["baz"].NodeType);
            Assert.AreEqual(YamlNodeType.Scalar, collectorFields.Children["xaz"].NodeType);
            Assert.AreEqual("bar", collectorFields.Children["foo"]);
            Assert.AreEqual("kaz", collectorFields.Children["baz"]);
            Assert.AreEqual("yaz", collectorFields.Children["xaz"]);
        }

        public void OpAmpAssertions(Config config, StreamReader sr)
        {
            YamlStream ys = new YamlStream();
            ys.Load(sr);
            YamlMappingNode root = (YamlMappingNode)ys.Documents[0].RootNode;

            Assert.IsTrue(root.Children.ContainsKey("extensions"));
            Assert.AreEqual(YamlNodeType.Mapping, root.Children["extensions"].NodeType);
            var extensions = (YamlMappingNode)root.Children["extensions"];

            if (config.RemotelyManaged)
            {
                Assert.IsTrue(extensions.Children.ContainsKey("opamp"));
                Assert.AreEqual(YamlNodeType.Mapping, extensions.Children["opamp"].NodeType);
                var opamp = (YamlMappingNode)extensions.Children["opamp"];

                Assert.IsTrue(opamp.Children.ContainsKey("remote_configuration_directory"));
                Assert.AreEqual(YamlNodeType.Scalar, opamp.Children["remote_configuration_directory"].NodeType);
                Assert.AreEqual(config.OpAmpFolder, opamp.Children["remote_configuration_directory"].ToString());
            }
            else
            {
                Assert.IsFalse(extensions.Children.ContainsKey("opamp"));
            }

            Assert.IsTrue(root.Children.ContainsKey("service"));
            Assert.AreEqual(YamlNodeType.Mapping, root.Children["service"].NodeType);
            var service = (YamlMappingNode)root.Children["service"];

            Assert.IsTrue(service.Children.ContainsKey("extensions"));
            Assert.AreEqual(YamlNodeType.Sequence, service.Children["extensions"].NodeType);
            var serviceExtensions = (YamlSequenceNode)service.Children["extensions"];
            if (config.RemotelyManaged)
            {
                Assert.IsTrue(serviceExtensions.Children.Contains("opamp"));
            }
            else
            {
                Assert.IsFalse(serviceExtensions.Children.Contains("opamp"));
            }
        }

        public void EphemeralAssertions(Config config, StreamReader sr)
        {
            YamlStream ys = new YamlStream();
            ys.Load(sr);
            YamlMappingNode root = (YamlMappingNode)ys.Documents[0].RootNode;

            Assert.IsTrue(root.Children.ContainsKey("extensions"));
            Assert.AreEqual(YamlNodeType.Mapping, root.Children["extensions"].NodeType);
            var extensions = (YamlMappingNode)root.Children["extensions"];

            Assert.IsTrue(extensions.Children.ContainsKey("sumologic"));
            Assert.AreEqual(YamlNodeType.Mapping, extensions.Children["sumologic"].NodeType);
            var sumologic = (YamlMappingNode)extensions.Children["sumologic"];

            if (config.Ephemeral)
            {
                Assert.IsTrue(sumologic.Children.ContainsKey("ephemeral"));
                Assert.AreEqual(YamlNodeType.Scalar, sumologic.Children["ephemeral"].NodeType);
                Assert.AreEqual("true", sumologic.Children["ephemeral"].ToString());
            }
            else
            {
                if (sumologic.Children.ContainsKey("ephemeral"))
                {
                    Assert.AreEqual(YamlNodeType.Scalar, sumologic.Children["ephemeral"].NodeType);
                    Assert.AreEqual("false", sumologic.Children["ephemeral"].ToString());
                }
            }
        }

        public void ApiAssertions(Config config, StreamReader sr)
        {
            YamlStream ys = new YamlStream();
            ys.Load(sr);
            YamlMappingNode root = (YamlMappingNode)ys.Documents[0].RootNode;

            Assert.IsTrue(root.Children.ContainsKey("extensions"));
            Assert.AreEqual(YamlNodeType.Mapping, root.Children["extensions"].NodeType);
            var extensions = (YamlMappingNode)root.Children["extensions"];

            Assert.IsTrue(extensions.Children.ContainsKey("sumologic"));
            Assert.AreEqual(YamlNodeType.Mapping, extensions.Children["sumologic"].NodeType);
            var sumologic = (YamlMappingNode)extensions.Children["sumologic"];

            Assert.IsTrue(sumologic.Children.ContainsKey("api_base_url"));
            Assert.AreEqual(YamlNodeType.Scalar, sumologic.Children["api_base_url"].NodeType);
            var apiBaseUrl = (YamlScalarNode)sumologic.Children["api_base_url"];
            Assert.AreEqual(config.Api, apiBaseUrl.ToString());
        }

        public void OpAmpApiAssertions(Config config, StreamReader sr)
        {
            YamlStream ys = new YamlStream();
            ys.Load(sr);
            YamlMappingNode root = (YamlMappingNode)ys.Documents[0].RootNode;

            Assert.IsTrue(root.Children.ContainsKey("extensions"));
            Assert.AreEqual(YamlNodeType.Mapping, root.Children["extensions"].NodeType);
            var extensions = (YamlMappingNode)root.Children["extensions"];

            Assert.IsTrue(extensions.Children.ContainsKey("opamp"));
            Assert.AreEqual(YamlNodeType.Mapping, extensions.Children["opamp"].NodeType);
            var opamp = (YamlMappingNode)extensions.Children["opamp"];

            Assert.IsTrue(opamp.Children.ContainsKey("endpoint"));
            Assert.AreEqual(YamlNodeType.Scalar, opamp.Children["endpoint"].NodeType);
            var endpoint = (YamlScalarNode)opamp.Children["endpoint"];
            Assert.AreEqual(config.OpAmpApi, endpoint.ToString());
        }

        public void TimezoneAssertions(Config config, StreamReader sr)
        {
            YamlStream ys = new YamlStream();
            ys.Load(sr);
            YamlMappingNode root = (YamlMappingNode)ys.Documents[0].RootNode;

            Assert.IsTrue(root.Children.ContainsKey("extensions"));
            Assert.AreEqual(YamlNodeType.Mapping, root.Children["extensions"].NodeType);
            var extensions = (YamlMappingNode)root.Children["extensions"];

            Assert.IsTrue(extensions.Children.ContainsKey("sumologic"));
            Assert.AreEqual(YamlNodeType.Mapping, extensions.Children["sumologic"].NodeType);
            var sumologic = (YamlMappingNode)extensions.Children["sumologic"];

            Assert.IsTrue(sumologic.Children.ContainsKey("time_zone"));
            Assert.AreEqual(YamlNodeType.Scalar, sumologic.Children["time_zone"].NodeType);
            var endpoint = (YamlScalarNode)sumologic.Children["time_zone"];
            Assert.AreEqual(config.Timezone, endpoint.ToString());
        }

        public void ClobberAssertions(Config config, StreamReader sr)
        {
            YamlStream ys = new YamlStream();
            ys.Load(sr);
            YamlMappingNode root = (YamlMappingNode)ys.Documents[0].RootNode;

            Assert.IsTrue(root.Children.ContainsKey("extensions"));
            Assert.AreEqual(YamlNodeType.Mapping, root.Children["extensions"].NodeType);
            var extensions = (YamlMappingNode)root.Children["extensions"];

            Assert.IsTrue(extensions.Children.ContainsKey("sumologic"));
            Assert.AreEqual(YamlNodeType.Mapping, extensions.Children["sumologic"].NodeType);
            var sumologic = (YamlMappingNode)extensions.Children["sumologic"];
            var endpoint = (YamlScalarNode)sumologic.Children["clobber"];
            if(config.Clobber){
                Assert.IsTrue(sumologic.Children.ContainsKey("clobber"));
                Assert.AreEqual(YamlNodeType.Scalar, sumologic.Children["clobber"].NodeType);
                Assert.AreEqual("true", endpoint.ToString());
            }
            else{
                if(sumologic.Children.ContainsKey("clobber")){
                    Assert.AreEqual(YamlNodeType.Scalar, sumologic.Children["clobber"].NodeType);
                    Assert.AreEqual("false", endpoint.ToString());
                }
            }
        }



        [TestMethod]
        public void TestUpdate_WithExtensionsBlock()
        {
            var filePath = Path.Combine(testDataPath, "with-extensions-block.yaml");
            var config = new Config { InstallationToken = "foobar", Ephemeral = true };
            config.SetCollectorFieldsFromTags(@"foo=bar,baz=kaz,xaz=yaz");

            using (MemoryStream ms = new MemoryStream())
            {
                var configUpdater = new ConfigUpdater(new StreamReader(filePath));
                configUpdater.Update(config);
                configUpdater.Save(new StreamWriter(ms));

                ms.Seek(0, SeekOrigin.Begin);

                StreamReader sr = new StreamReader(ms);
                while (!sr.EndOfStream)
                {
                    Console.WriteLine(sr.ReadLine());
                }

                ms.Seek(0, SeekOrigin.Begin);

                InstallationTokenAssertions(config, sr);
            }
        }

        [TestMethod]
        public void TestUpdate_WithoutExtensionsBlock()
        {
            var filePath = Path.Combine(testDataPath, "without-extensions-block.yaml");
            var config = new Config { InstallationToken = "foobar", Ephemeral = false };
            config.SetCollectorFieldsFromTags(@"foo=bar,baz=kaz,xaz=yaz");

            using (MemoryStream ms = new MemoryStream())
            {
                var configUpdater = new ConfigUpdater(new StreamReader(filePath));
                configUpdater.Update(config);
                configUpdater.Save(new StreamWriter(ms));

                ms.Seek(0, SeekOrigin.Begin);

                StreamReader sr = new StreamReader(ms);
                while (!sr.EndOfStream)
                {
                    Console.WriteLine(sr.ReadLine());
                }

                ms.Seek(0, SeekOrigin.Begin);

                InstallationTokenAssertions(config, sr);
            }
        }

        [TestMethod]
        public void TestUpdate_NoIndentation()
        {
            var filePath = Path.Combine(testDataPath, "no-indentation.yaml");
            var config = new Config { InstallationToken = "foobar" };
            config.SetCollectorFieldsFromTags(@"foo=bar,baz=kaz,xaz=yaz");

            using (MemoryStream ms = new MemoryStream())
            {
                var configUpdater = new ConfigUpdater(new StreamReader(filePath));
                configUpdater.Update(config);
                configUpdater.Save(new StreamWriter(ms));

                ms.Seek(0, SeekOrigin.Begin);

                StreamReader sr = new StreamReader(ms);
                while (!sr.EndOfStream)
                {
                    Console.WriteLine(sr.ReadLine());
                }

                ms.Seek(0, SeekOrigin.Begin);

                InstallationTokenAssertions(config, sr);
            }
        }

        [TestMethod]
        [ExpectedException(typeof(EmptyConfigException), "Loading an empty config did not throw an EmptyConfigException.")]
        public void TestUpdate_Empty()
        {
            var filePath = Path.Combine(testDataPath, "empty.yaml");
            var config = new Config { InstallationToken = "foobar" };
            config.SetCollectorFieldsFromTags(@"foo=bar,baz=kaz,xaz=yaz");

            using (MemoryStream ms = new MemoryStream())
            {
                var configUpdater = new ConfigUpdater(new StreamReader(filePath));
            }
        }

        [TestMethod]
        [ExpectedException(typeof(YamlDotNet.Core.SyntaxErrorException), "Loading an invalid config did not throw a YamlDotNet.Core.SyntaxErrorException.")]
        public void TestUpdate_Invalid()
        {
            var filePath = Path.Combine(testDataPath, "invalid.yaml");
            var config = new Config { InstallationToken = "foobar" };
            config.SetCollectorFieldsFromTags(@"foo=bar,baz=kaz,xaz=yaz");

            using (MemoryStream ms = new MemoryStream())
            {
                var configUpdater = new ConfigUpdater(new StreamReader(filePath));
            }
        }

        [TestMethod]
        public void TestUpdate_OpAmp()
        {
            var filePath = Path.Combine(testDataPath, "with-extensions-block.yaml");
            var config = new Config { InstallationToken = "foobar", Ephemeral = true, RemotelyManaged = true, OpAmpFolder = "/opamp" };
            config.SetCollectorFieldsFromTags(@"foo=bar,baz=kaz,xaz=yaz");

            using (MemoryStream ms = new MemoryStream())
            {
                var configUpdater = new ConfigUpdater(new StreamReader(filePath));
                configUpdater.Update(config);
                configUpdater.Save(new StreamWriter(ms));

                ms.Seek(0, SeekOrigin.Begin);

                StreamReader sr = new StreamReader(ms);
                while (!sr.EndOfStream)
                {
                    Console.WriteLine(sr.ReadLine());
                }

                ms.Seek(0, SeekOrigin.Begin);

                OpAmpAssertions(config, sr);
            }
        }

        [TestMethod]
        [ExpectedException(typeof(MissingConfigurationException), "OpAmpFolder")]
        public void TestUpdate_OpAmpNoFolder()
        {
            var filePath = Path.Combine(testDataPath, "with-extensions-block.yaml");
            var config = new Config { InstallationToken = "foobar", Ephemeral = true, RemotelyManaged = true };
            config.SetCollectorFieldsFromTags(@"foo=bar,baz=kaz,xaz=yaz");

            using (MemoryStream ms = new MemoryStream())
            {
                var configUpdater = new ConfigUpdater(new StreamReader(filePath));
                configUpdater.Update(config);
                configUpdater.Save(new StreamWriter(ms));
            }
        }

        [TestMethod]
        public void TestUpdate_NoOpAmpWithFolder()
        {
            var filePath = Path.Combine(testDataPath, "with-extensions-block.yaml");
            var config = new Config { InstallationToken = "foobar", Ephemeral = true, RemotelyManaged = false, OpAmpFolder = "/opamp" };
            config.SetCollectorFieldsFromTags(@"foo=bar,baz=kaz,xaz=yaz");

            using (MemoryStream ms = new MemoryStream())
            {
                var configUpdater = new ConfigUpdater(new StreamReader(filePath));
                configUpdater.Update(config);
                configUpdater.Save(new StreamWriter(ms));

                ms.Seek(0, SeekOrigin.Begin);

                StreamReader sr = new StreamReader(ms);
                while (!sr.EndOfStream)
                {
                    Console.WriteLine(sr.ReadLine());
                }

                ms.Seek(0, SeekOrigin.Begin);

                OpAmpAssertions(config, sr);
            }
        }

        [TestMethod]
        public void TestUpdate_Ephemeral()
        {
            var filePath = Path.Combine(testDataPath, "with-extensions-block.yaml");
            var config = new Config { InstallationToken = "foobar", Ephemeral = true };
            config.SetCollectorFieldsFromTags(@"foo=bar,baz=kaz,xaz=yaz");

            using (MemoryStream ms = new MemoryStream())
            {
                var configUpdater = new ConfigUpdater(new StreamReader(filePath));
                configUpdater.Update(config);
                configUpdater.Save(new StreamWriter(ms));

                ms.Seek(0, SeekOrigin.Begin);

                StreamReader sr = new StreamReader(ms);
                while (!sr.EndOfStream)
                {
                    Console.WriteLine(sr.ReadLine());
                }

                ms.Seek(0, SeekOrigin.Begin);

                EphemeralAssertions(config, sr);
            }
        }

        [TestMethod]
        public void TestUpdate_NotEphemeral()
        {
            var filePath = Path.Combine(testDataPath, "with-extensions-block.yaml");
            var config = new Config { InstallationToken = "foobar", Ephemeral = false };
            config.SetCollectorFieldsFromTags(@"foo=bar,baz=kaz,xaz=yaz");

            using (MemoryStream ms = new MemoryStream())
            {
                var configUpdater = new ConfigUpdater(new StreamReader(filePath));
                configUpdater.Update(config);
                configUpdater.Save(new StreamWriter(ms));

                ms.Seek(0, SeekOrigin.Begin);

                StreamReader sr = new StreamReader(ms);
                while (!sr.EndOfStream)
                {
                    Console.WriteLine(sr.ReadLine());
                }

                ms.Seek(0, SeekOrigin.Begin);

                EphemeralAssertions(config, sr);
            }
        }

        [TestMethod]
        public void TestUpdate_Api()
        {
            var filePath = Path.Combine(testDataPath, "with-extensions-block.yaml");
            var config = new Config { InstallationToken = "foobar", Api = "http://apiurl.local" };
            config.SetCollectorFieldsFromTags(@"foo=bar,baz=kaz,xaz=yaz");

            using (MemoryStream ms = new MemoryStream())
            {
                var configUpdater = new ConfigUpdater(new StreamReader(filePath));
                configUpdater.Update(config);
                configUpdater.Save(new StreamWriter(ms));

                ms.Seek(0, SeekOrigin.Begin);

                StreamReader sr = new StreamReader(ms);
                while (!sr.EndOfStream)
                {
                    Console.WriteLine(sr.ReadLine());
                }

                ms.Seek(0, SeekOrigin.Begin);

                ApiAssertions(config, sr);
            }
        }

        [TestMethod]
        public void TestUpdate_OpAmpApi()
        {
            var filePath = Path.Combine(testDataPath, "with-extensions-block.yaml");
            var config = new Config { InstallationToken = "foobar", RemotelyManaged = true, OpAmpApi = "http://opampapiurl.local", OpAmpFolder = "/opamp" };
            config.SetCollectorFieldsFromTags(@"foo=bar,baz=kaz,xaz=yaz");

            using (MemoryStream ms = new MemoryStream())
            {
                var configUpdater = new ConfigUpdater(new StreamReader(filePath));
                configUpdater.Update(config);
                configUpdater.Save(new StreamWriter(ms));

                ms.Seek(0, SeekOrigin.Begin);

                StreamReader sr = new StreamReader(ms);
                while (!sr.EndOfStream)
                {
                    Console.WriteLine(sr.ReadLine());
                }

                ms.Seek(0, SeekOrigin.Begin);

                OpAmpApiAssertions(config, sr);
            }
        }



        [TestMethod]
        public void TestUpdate_Timezone()
        {
            var filePath = Path.Combine(testDataPath, "with-extensions-block.yaml");
            var config = new Config { InstallationToken = "foobar", Timezone = "UTC" };
            config.SetCollectorFieldsFromTags(@"foo=bar,baz=kaz,xaz=yaz");

            using (MemoryStream ms = new MemoryStream())
            {
                var configUpdater = new ConfigUpdater(new StreamReader(filePath));
                configUpdater.Update(config);
                configUpdater.Save(new StreamWriter(ms));

                ms.Seek(0, SeekOrigin.Begin);

                StreamReader sr = new StreamReader(ms);
                while (!sr.EndOfStream)
                {
                    Console.WriteLine(sr.ReadLine());
                }

                ms.Seek(0, SeekOrigin.Begin);

                TimezoneAssertions(config, sr);
            }
        }

        [TestMethod]
        public void TestUpdate_Clobber()
        {
            var filePath = Path.Combine(testDataPath, "with-extensions-block.yaml");
            var config = new Config { InstallationToken = "foobar", Clobber = true };
            config.SetCollectorFieldsFromTags(@"foo=bar,baz=kaz,xaz=yaz");

            using (MemoryStream ms = new MemoryStream())
            {
                var configUpdater = new ConfigUpdater(new StreamReader(filePath));
                configUpdater.Update(config);
                configUpdater.Save(new StreamWriter(ms));

                ms.Seek(0, SeekOrigin.Begin);

                StreamReader sr = new StreamReader(ms);
                while (!sr.EndOfStream)
                {
                    Console.WriteLine(sr.ReadLine());
                }

                ms.Seek(0, SeekOrigin.Begin);

                ClobberAssertions(config, sr);
            }
        }

    }
}
