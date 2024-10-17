package cn.xports.smartplay.programme;

import java.io.*;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.*;
import java.util.stream.Collectors;


public class Module {

    private String name;

    private List<Item> items = new ArrayList();

    private List<Recipe> recipes = new ArrayList();

    private List<String> imports = new ArrayList();

    public String toString() {
        StringBuilder builder = new StringBuilder();
        builder.append("module ");
        builder.append(name);
        builder.append("\n{");
        if (!imports.isEmpty()) {
            builder.append("\n  imports\n  {");
            imports.forEach(str -> {
                builder.append("\n  ");
                builder.append(str);
                builder.append(",");
            });
            builder.append("\n  }");
        }
        items.forEach(i -> {
            builder.append("\n\n");
            builder.append(i.toString());
        });
        recipes.forEach(r -> {
            builder.append("\n\n");
            builder.append(r.toString());
        });
        builder.append("\n");
        builder.append("}");
        return builder.toString();
    }

    public void parseRaw(String raw) {
        raw = raw.trim();
        Reader reader = new Reader(raw);
        String firstline = reader.readUtil('{');
        this.name = firstline.replace("module", "")
                .replace("{", "").trim();

        while (true) {
            String inner = reader.readUtil('}').trim();
            if (inner.length() <= 1) {
                break;
            }
            if (inner.startsWith("imports")) {
                inner = inner.replace("imports", "").replace("{", "").replace("}", "").trim();
                Arrays.stream(inner.split(",")).filter(Module::isNotBlank)
                        .forEach(str -> this.imports.add(str));
            } else if (inner.startsWith("item")) {
                Item item = new Item();
                item.parse(inner);
                this.items.add(item);
            } else if (inner.startsWith("recipe")) {
                Recipe recipe = new Recipe();
                recipe.parse(inner);
                this.recipes.add(recipe);
            }
        }
    }


    static class Item {

        private String name;

        private Map<String, String> props = new TreeMap();

        public String toString() {
            StringBuilder builder = new StringBuilder();
            builder.append("  item ");
            builder.append(name);
            builder.append("\n  {");
            props.forEach((k, v) -> {
                builder.append("\n    ");
                builder.append(k);
                if (isNotBlank(v)) {
                    builder.append(" = ");
                    builder.append(v);
                }
                builder.append(",");
            });
            builder.append("\n");
            builder.append("  }");
            return builder.toString();
        }

        public void parse(String raw) {
            Reader reader = new Reader(raw);
            String firstLine = reader.readUtil('{');
            this.name = firstLine.replace("item", "").replace("{", "").trim();
            Arrays.stream(reader.readUtil('}').split(","))
                    .map(str -> str.replace("}", "").trim())
                    .filter(Module::isNotBlank)
                    .forEach(str -> {
                        if (str.contains("=")) {
                            String[] arr = str.split("=");
                            props.put(arr[0].trim(), arr[1].trim());
                        } else {
                            props.put(str.trim(), "");
                        }
                    });
        }
    }


    static class Recipe {
        private String name;

        private Map<String, Integer> sources = new TreeMap();

        private String result;

        private int resultCount = 1;

        private Map<String, String> props = new TreeMap();

        private List<String> keeps = new ArrayList();

        public String toString() {
            StringBuilder builder = new StringBuilder();
            builder.append("  recipe ");
            builder.append(name);
            builder.append("\n  {");
            sources.forEach((k, v) -> {
                builder.append("\n    ");
                builder.append(k);
                if (v > 1) {
                    builder.append(" = ");
                    builder.append(v);
                }
                builder.append(",");
            });
            keeps.forEach(k -> {
                builder.append("\n    keep ");
                builder.append(k);
                builder.append(",");
            });

            builder.append("\n \n    Result : ");
            builder.append(this.result);
            if (resultCount > 1) {
                builder.append(" = ");
                builder.append(resultCount);
            }
            builder.append(",");
            props.forEach((k, v) -> {
                builder.append("\n    ");
                builder.append(k);
                builder.append(" : ");
                builder.append(v);
                builder.append(",");
            });
            builder.append("\n");
            builder.append("  }");
            return builder.toString();
        }

        public void parse(String raw) {
            Reader reader = new Reader(raw);
            String firstline = reader.readUtil('{');
            this.name = firstline.replace("recipe", "").replace("{", "").trim();
            boolean complete = false;
            List<String> list = Arrays.stream(reader.readUtil('}').split(","))
                    .map(str -> str.replace("}", "").trim())
                    .filter(Module::isNotBlank)
                    .collect(Collectors.toList());
            for (String str : list) {
                if (str.startsWith("Result")) {
                    complete = true;
                    String resultSet = str.split(":")[1];
                    String[] arr = resultSet.split("=");
                    if (arr.length > 1) {
                        this.resultCount = Integer.parseInt(arr[1].trim());
                    }
                    this.result = arr[0].trim();
                    continue;
                }
                if (!str.contains(":")) {
                    if (str.startsWith("keep")) {
                        this.keeps.add(str.replace("keep", "").trim());
                    } else {
                        String[] arr = str.split("=");
                        int count = 1;
                        if (arr.length > 1) {
                            count = Integer.parseInt(arr[1].trim());
                        }
                        sources.put(arr[0].trim(), count);
                    }
                } else {
                    String[] arr = str.split(":");
                    String value = "";
                    if (arr.length > 1) {
                        value = arr[1].trim();
                    }
                    props.put(arr[0].trim(), value);
                }

            }
        }
    }


    static class Reader {
        private String raw;

        private int index = -1;

        public Reader(String raw) {
            this.raw = raw;
        }

        public String readUtil(char ch) {
            StringBuilder builder = new StringBuilder();
            while (index < raw.length() - 1) {
                index++;
                char c = raw.charAt(index);
                builder.append(c);
                if (c == ch) {
                    return builder.toString();
                }
            }
            return builder.toString();
        }

    }

    private static List<Path> recuseFindTxt(Path path) {
        List<Path> txtPath = new ArrayList<>();
        for (File f : path.toFile().listFiles()) {
            Path child = f.toPath();
            if (f.isFile() && f.getName().endsWith(".txt")) {
                txtPath.add(child);
            }
            if (f.isDirectory()) {
                txtPath.addAll(recuseFindTxt(child));
            }
        }
        return txtPath;
    }

    private static boolean isNotBlank(String str) {
        return str != null && str.trim().length() > 0;
    }

    private static String toString(InputStream is, String charset) throws IOException {
        BufferedReader reader = new BufferedReader(new InputStreamReader(is, charset));
        String txt = reader.lines().collect(Collectors.joining("\n"));
        is.close();
        return txt;

    }

    public static void main(String[] args) throws IOException {
        String path = "./Contents/mods";
        for (File child : Paths.get(path).toFile().listFiles()) {
            Path scriptPath;
            if ((scriptPath = child.toPath().resolve("media/scripts")).toFile().exists()) {
                List<Path> txtPath = recuseFindTxt(scriptPath);
                for (Path txt : txtPath) {
                    String raw = toString(Files.newInputStream(txt), "UTF-8");
                    Module module = new Module();
                    module.parseRaw(raw);
                    System.out.println(module.toString());
                    Files.newOutputStream(txt).write(module.toString().getBytes(StandardCharsets.UTF_8));
                }

            }
        }
    }
}

